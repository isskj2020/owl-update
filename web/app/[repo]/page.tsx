'use client'

import FileViewPage from '@/components/FileViewPage/FileViewPage'

import { useEffect, useState } from 'react'
import type { FileItem, ApiState } from '@/types/types'
import {
  apiFetchRepoFiles,
  apiRepoAddDirectory,
  apiRepoAddFile,
  errorMessage,
} from '@/lib/api'
import { owlPath } from '@/lib/owlpath'
import { useRouter } from 'next/navigation'
import { useObjectState } from '@/lib/react'

export default function Page() {
  const router = useRouter()
  const path = owlPath()

  const [ apiState, updateApi ] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  const [files, setFiles] = useState<FileItem[]>([])
  const [reload, setReload] = useState<number>(0)

  async function loadFiles() {
    updateApi({ loading: true })
    apiFetchRepoFiles(path.repo)
      .then((res) => setFiles(res.data.files))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onAddDirectory(filepath: string) {
    updateApi({ loading: true })
    apiRepoAddDirectory(path.repo, filepath)
      .then((_) => setReload(prev => prev+1))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onAddFile(filepath: string, file: File) {
    updateApi({ loading: true })
    apiRepoAddFile(path.repo, filepath, file)
      .then((_) => setReload(prev => prev+1))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  useEffect(() => {
    loadFiles()
  }, [reload])

  return (
    <FileViewPage
      repository={path.repo}
      apiState={apiState}
      files={files}
      onAddDirectory={onAddDirectory}
      onAddFile={onAddFile}
      onNavigate={(url) => router.push(url)}
    />
  )
}
