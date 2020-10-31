module.exports = {
  async onPreBuild({ utils: { run } }) {
    await run.command('bundle exec rake tags')
  },

  async onSuccess({ utils: { run } }) {
    await run.command('bundle exec drumknott refresh')
  },
}
