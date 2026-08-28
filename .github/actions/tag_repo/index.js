import * as core from '@actions/core'
import { context, getOctokit } from '@actions/github'
import { readFile } from 'node:fs/promises'

const VERSION_FILE = './VERSION'

let octokitSingleton = null

function getOctokitSingleton() {
  if (octokitSingleton) {
    return octokitSingleton;
  }
  const githubToken = core.getInput('token');
  octokitSingleton = getOctokit(githubToken);
  return octokitSingleton;
}

async function getTag(version) {
  const octoKit = getOctokitSingleton()
  try {
    core.info("Fetching tag")
    const result = await octoKit.rest.repos.getReleaseByTag({
      ...context.repo,
      tag: version
    })
    return result.data.id
  } catch (_error) {
    return null
  }
}

async function createTag(tag) {
  const octoKit = getOctokitSingleton()
  await octoKit.rest.repos.createRelease({
    ...context.repo,
    tag_name: tag,
    name: `v${tag}`
  })
  core.info('Tag created')
}

async function run() {
  try {
    const content = await readFile(VERSION_FILE, { encoding: "utf8" })
    const version = content.trim()

    const gitHubTag = await getTag(version)

    core.setOutput('version', version)

    if (gitHubTag !== null) {
      core.info(`Tag ${version} already exists`)
      core.setOutput('created', 'false')
    } else {
      core.info(`Creating tag for ${version}`)
      await createTag(version)
      core.setOutput('created', 'true')
    }


  } catch (error) {
    core.setFailed(error.message);
  }
}

run()
