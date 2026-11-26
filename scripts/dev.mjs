import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {syncDocs} from './sync-docs.mjs';

const root = process.cwd();
const roots = ['AZ-900 Prep', 'azure-labs', 'docker-notes', 'kubernetes-notes', 'site-content'];
let timer;
let syncing = false;
let syncAgain = false;

syncDocs({ clean: true });
const child = spawn(process.execPath, ['run', 'astro', 'dev'], { stdio: 'inherit' });

function scheduleSync() {
  clearTimeout(timer);
  timer = setTimeout(() => {
    if (syncing) {
      syncAgain = true;
      return;
    }
    syncing = true;
    try {
      syncDocs({ clean: false });
    } finally {
      syncing = false;
      if (syncAgain) {
        syncAgain = false;
        scheduleSync();
      }
    }
  }, 180);
}

const watchers = roots.map((directory) => fs.watch(path.join(root, directory), { recursive: true }, (_event, filename) => {
  if (filename && !/\.md$|\.(?:png|jpe?g|svg|webp)$/i.test(filename.toString())) return;
  scheduleSync();
}));
watchers.push(fs.watch(path.join(root, 'CONTRIBUTING.md'), scheduleSync));

function stop() {
  for (const watcher of watchers) watcher.close();
  child.kill();
}

process.on('SIGINT', stop);
process.on('SIGTERM', stop);
child.on('exit', (code) => {
  for (const watcher of watchers) watcher.close();
  process.exit(code ?? 0);
});
