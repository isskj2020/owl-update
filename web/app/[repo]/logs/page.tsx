'use client'

import { useEffect, useState } from 'react'
import { apiFetchRepoLogs, errorMessage } from '@/lib/api'
import RepositoryLogPage from '@/components/RepositoryLogPage/RepositoryLogPage'
import type { GitLog, ApiState } from '@/types/types'
import { owlPath } from '@/lib/owlpath'
import { useRouter } from 'next/navigation'
import { useObjectState } from '@/lib/react'

export default function Page() {
  const router = useRouter()
  const path = owlPath()

  const [logs, setLogs] = useState<GitLog[]>([])
  const [ apiState, updateApi ] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  async function loadRepositoryLogs() {
    apiFetchRepoLogs(path.repo)
      .then((x) => setLogs(x.data.logs))
      .catch((e) => updateApi({ error: errorMessage(e.message) }))
      .finally(() => updateApi({ loading: false }))
  }

  useEffect(() => {
    loadRepositoryLogs()
  }, [])

  return (
    <RepositoryLogPage
      repository={path.repo}
      apiState={apiState}
      logs={logs}
      onNavigate={(url) => router.push(url) }
    />
  )
}
