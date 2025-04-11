module.exports = {
  async onPreBuild({ utils: { run } }) {
    await run.command('bundle exec rake tags')
  },

  async onBuild({ utils: { run } }) {
    await run.command('npx pagefind --source _site')
    await run.command('bin/load_remotes')
  },
}
