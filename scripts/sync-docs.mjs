import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const docsRelative = path.join('src', 'content', 'docs');
const docsRoot = path.resolve(root, docsRelative);
const repoUrl = 'https://github.com/yasuomaidana/dev-ops-notes';
const sections = new Map([
  ['AZ-900 Prep', 'az-900-prep'],
  ['azure-labs', 'azure-labs'],
  ['docker-notes', 'docker-notes'],
  ['kubernetes-notes', 'kubernetes-notes'],
]);
const linkPattern = /(?<open>!?\[)(?<label>[^\]]*?)\]\((?<href>[^)]+)\)/g;
const winRootPattern = /^C:\/Users\/yasuo\.maidana\/GolandProjects\/dev-ops-notes\/(.+)$/i;

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const absolute = path.join(dir, entry.name);
    return entry.isDirectory() ? walk(absolute) : [absolute];
  });
}

function relativeToRoot(absolute) {
  return path.relative(root, absolute).split(path.sep).join('/');
}

function slug(value) {
  return value.normalize('NFKD').replace(/[\u0300-\u036f]/g, '')
    .toLowerCase().replace(/&/g, ' and ').replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '') || 'page';
}

function outputFor(source) {
  const rel = relativeToRoot(source);
  if (rel === 'site-content/index.md') return path.join(docsRoot, 'index.md');
  if (rel === 'CONTRIBUTING.md') return path.join(docsRoot, 'contributing.md');
  const parts = rel.split('/');
  const section = sections.get(parts.shift());
  const filename = parts.pop();
  const directories = parts.map(slug);
  const stem = path.parse(filename).name;
  const outputName = ['readme', 'index', 'content'].includes(stem.toLowerCase())
    ? 'index.md'
    : `${slug(stem)}.md`;
  return path.join(docsRoot, section, ...directories, outputName);
}

function routeFor(output) {
  let route = path.relative(docsRoot, output).split(path.sep).join('/').replace(/\.md$/, '');
  if (route.endsWith('/index')) route = route.slice(0, -'/index'.length);
  if (route === 'index') route = '';
  return `/${route ? `${route}/` : ''}`;
}

function encodePath(value) {
  return value.split('/').map((part) => encodeURIComponent(part)
    .replace(/%2D/gi, '-').replace(/%2E/gi, '.').replace(/%5F/gi, '_').replace(/%7E/gi, '~')).join('/');
}

function titleAndBody(sourceText, source) {
  const lines = sourceText.replace(/^\uFEFF/, '').split(/\r?\n/);
  const titleIndex = lines.findIndex((line) => /^#\s+/.test(line));
  const title = titleIndex >= 0 ? lines.splice(titleIndex, 1)[0].replace(/^#\s+/, '').trim() : path.parse(source).name;
  while (lines.length && !lines[0].trim()) lines.shift();
  return { title, body: `${lines.join('\n').trimEnd()}\n` };
}

function transformLink(source, output, match, mapping, assetMapping) {
  const href = match.groups.href.trim();
  const isImage = match.groups.open === '![';
  if (href.startsWith('#') || href.startsWith('//') || /^(https?:|mailto:|tel:|data:)/i.test(href)) return match[0];

  let pathPart = href;
  let suffix = '';
  if (!/^[A-Za-z]:\//.test(href)) {
    const suffixAt = href.search(/[?#]/);
    if (suffixAt >= 0) {
      pathPart = href.slice(0, suffixAt);
      suffix = href.slice(suffixAt);
    }
  }
  let decoded;
  try {
    decoded = decodeURIComponent(pathPart).replace(/\\/g, '/');
  } catch {
    return match[0];
  }

  let line = null;
  let targetSource;
  const absolute = winRootPattern.exec(decoded);
  if (absolute) {
    decoded = absolute[1];
    const lineMatch = /:(\d+)$/.exec(decoded);
    if (lineMatch) {
      line = lineMatch[1];
      decoded = decoded.slice(0, lineMatch.index);
    }
    targetSource = path.resolve(root, ...decoded.split('/'));
  } else {
    const lineMatch = /^([A-Za-z]:\/.*):(\d+)$/.exec(decoded);
    if (lineMatch && winRootPattern.test(lineMatch[1])) {
      line = lineMatch[2];
      const absoluteLine = winRootPattern.exec(lineMatch[1]);
      targetSource = path.resolve(root, ...absoluteLine[1].split('/'));
    } else {
      if (!decoded || decoded.startsWith('/')) return match[0];
      targetSource = path.resolve(path.dirname(source), ...decoded.split('/'));
    }
  }

  const targetRel = relativeToRoot(targetSource);
  if (targetRel === '..' || targetRel.startsWith(`..${path.posix.sep}`)) return match[0];
  const outputTarget = mapping.get(targetRel) || assetMapping.get(targetRel);

  if (isImage) {
    if (!outputTarget) return match[0];
    const relativeAsset = path.relative(path.dirname(output), outputTarget).split(path.sep).join('/');
    return `![${match.groups.label}](${encodePath(relativeAsset)}${suffix})`;
  }

  if (outputTarget && mapping.has(targetRel)) {
    const relativeRoute = path.posix.relative(routeFor(output).slice(1), routeFor(outputTarget).slice(1));
    let url = relativeRoute || './';
    if (routeFor(outputTarget).endsWith('/') && !url.endsWith('/')) url += '/';
    return `[${match.groups.label}](${encodePath(url)}${suffix})`;
  }

  if (fs.existsSync(targetSource)) {
    const kind = fs.statSync(targetSource).isDirectory() ? 'tree' : 'blob';
    let url = `${repoUrl}/${kind}/main/${encodePath(targetRel)}`;
    if (line) url += `#L${line}`;
    else if (suffix.startsWith('#')) url += suffix;
    return `[${match.groups.label}](${url})`;
  }

  return match[0];
}

function sourceFiles() {
  const paths = [...sections.keys()].flatMap((section) => walk(path.join(root, section)))
    .filter((file) => file.toLowerCase().endsWith('.md'))
    .filter((file) => !relativeToRoot(file).split('/').some((part) => ['.idea', '.terraform'].includes(part.toLowerCase())))
    .sort();
  paths.push(path.join(root, 'CONTRIBUTING.md'), path.join(root, 'site-content', 'index.md'));
  return paths.filter((file) => fs.existsSync(file));
}

export function syncDocs({ clean = true } = {}) {
  const fromRoot = path.relative(root, docsRoot);
  if (!fromRoot.startsWith(`src${path.sep}content${path.sep}docs`)) {
    throw new Error(`Refusing to write outside generated docs directory: ${docsRoot}`);
  }
  if (clean && fs.existsSync(docsRoot)) fs.rmSync(docsRoot, { recursive: true, force: true });
  fs.mkdirSync(docsRoot, { recursive: true });

  const sources = sourceFiles();
  const mapping = new Map(sources.map((source) => [relativeToRoot(source), outputFor(source)]));
  const targets = [...mapping.values()];
  const collisions = targets.filter((file, index) => targets.indexOf(file) !== index);
  if (collisions.length) throw new Error(`Page route collision: ${[...new Set(collisions)].join(', ')}`);

  const assetRoot = path.join(root, 'AZ-900 Prep', 'assets');
  const assets = fs.existsSync(assetRoot) ? walk(assetRoot).filter((file) => fs.statSync(file).isFile()) : [];
  const assetMapping = new Map(assets.map((file) => [
    relativeToRoot(file), path.join(docsRoot, 'az-900-prep', 'assets', path.relative(assetRoot, file)),
  ]));
  const generated = new Map();

  for (const source of sources) {
    const output = mapping.get(relativeToRoot(source));
    const sourceText = fs.readFileSync(source, 'utf8');
    let pageText;
    if (relativeToRoot(source) === 'site-content/index.md') {
      pageText = sourceText;
    } else {
      const { title, body } = titleAndBody(sourceText, source);
      pageText = `---\ntitle: ${JSON.stringify(title)}\n---\n\n${body}`;
    }
    pageText = pageText.replace(linkPattern, (...args) => {
      const full = args[0];
      const groups = args.at(-1);
      return transformLink(source, output, { 0: full, groups }, mapping, assetMapping);
    });
    generated.set(output, pageText);
  }

  for (const source of assets) {
    generated.set(assetMapping.get(relativeToRoot(source)), fs.readFileSync(source));
  }

  const manifestPath = path.join(docsRoot, '.sync-manifest.json');
  const oldFiles = fs.existsSync(manifestPath) ? JSON.parse(fs.readFileSync(manifestPath, 'utf8')) : [];
  const newFiles = [...generated.keys()].map((file) => path.relative(docsRoot, file).split(path.sep).join('/'));
  for (const oldFile of oldFiles) {
    if (!newFiles.includes(oldFile)) fs.rmSync(path.join(docsRoot, oldFile), { force: true });
  }
  for (const [file, contents] of generated) {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    const bytes = Buffer.isBuffer(contents) ? contents : Buffer.from(contents, 'utf8');
    if (!fs.existsSync(file) || !fs.readFileSync(file).equals(bytes)) fs.writeFileSync(file, bytes);
  }
  fs.writeFileSync(manifestPath, JSON.stringify(newFiles, null, 2));
  console.log(`Synced ${sources.length} Markdown pages and ${assets.length} image assets to src/content/docs.`);
}

if (import.meta.main) syncDocs();
