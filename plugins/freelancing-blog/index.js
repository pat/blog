module.exports = {
  async onPreBuild({ utils: { run } }) {
    await run.command('bundle exec rake tags')
    await run.command('bundle exec drumknott refresh')
    await run.command('bin/load_remotes')
  },

  async onSuccess({ utils: { run } }) {
    //
  },
}
