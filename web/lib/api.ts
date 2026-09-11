'use client'

import api from './base_api'

export function apiFetchAlive() {
  return api().get('/alive').then((x) => x.data.message == 'alive')
}


export function apiLogin(email: string, password: string, rememberMe: boolean) {
    return api().post('/login', {
      email: email,
      password: password,
      remember_me: rememberMe,
    })
}

export function apiSignup(name: string, email: string, password: string, rememberMe: boolean) {
    return api().post('/signup', {
      name: name,
      email: email,
      password: password,
      remember_me: rememberMe,
    })
}

export function apiAuth() {
    return api().get('/verify')
}

export function apiLogout() {
    return api().post('/logout')
}

export function errorMessage(error) {
  if (error.response.data) {
    return error.response.data.message
  } else {
    return error.message
  }
}

export function apiFetchRepositoryNames() {
  return api().get(`/owl/repos`).then((res) => {
    const repos = res.data.repos
    if (repos.length == 0) {
      return []
    }
    return repos.map((x) => x.name)
  })
}

export function apiCreateRepo(name: string, description: string, remoteOrigin: string) {
  return api().post('/owl/create', {
    name: name,
    description: description,
    remote_origin: remoteOrigin,
  })
}

export function apiFetchRepoFiles(repo: string) {
  return api().get(`/owl/${repo}/files`)
}

export function apiFetchRepoStatus(repo: string) {
  return api().get(`/owl/${repo}/status`)
}

export function apiFetchRepoLogs(repo: string) {
  return api().get(`/owl/${repo}/logs`)
}

export function apiFetchRepoDiffs(repo: string) {
  return api().get(`/owl/${repo}/diffs`)
}


export function apiRepoAddFile(repo: string, filepath: string, file: File) {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('json', JSON.stringify({ filepath: filepath }))
  return api().post(`/owl/${repo}/file/add`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    }
  })
}

export function apiRepoAddDirectory(repo: string, filepath: string) {
  return api().post(`/owl/${repo}/dir/add`, { filepath: filepath })
}

export function apiRepoCommit(repo: string, filepath: string, message: string) {
  return api().post(`/owl/${repo}/commit`, { filepath: filepath, message: message })
}

export function apiRepoUpdate(repo: string, filepath: string, axioms: object) {
  return api().post(`/owl/${repo}/update`, { filepath: filepath, axioms: axioms }) 
}

export function apiRepoReset(repo: string, filepath: string) {
  return api().post(`/owl/${repo}/reset`, { filepath: filepath }) 
}


export function apiOWLLoad(repo: string, filepath: string) {
  return api().post(`/owl/${repo}/load`, { filepath: filepath })
}

export function apiOWLLoadShapley(repo: string, filepath: string) {
  return api().post(`/owl/${repo}/load/shapley`, { filepath: filepath })
}

export function apiSuggestLLM(axioms: object) {
  return api().post(`/owl/ml/similarity/llm`, axioms)
}

export function apiSuggestEmbedding(axioms: object) {
  return api().post(`/owl/ml/similarity/embedding`, axioms)
}

export function apiMLModels() {
  return api().get(`/owl/ml/models`).then((x) => {
      var info = 'ML Info\n'
      x.data.models.forEach((m) => {
        info += `${m.info}\n`
      })
      return info
  })
}
