'use client'

import { useObjectState } from '@/lib/react'
import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import RepositoriesPage from '@/components/RepositoriesPage/RepositoriesPage'
import { apiFetchRepositoryNames, errorMessage } from '@/lib/api'
import type { ApiState } from '@/types/types'


export default function Page() {
  const router = useRouter()
  const [ repositories, setRepositories ] = useState<string[]>([])
  const [ apiState, updateApi ] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  async function loadRepositories() {
    updateApi({ loading: true })
    apiFetchRepositoryNames()
       .then((x) => setRepositories(x))
       .catch((e) => updateApi({ error: errorMessage(e) }))
       .finally(() => updateApi({ loading: false }))
  }

  useEffect(() => {
    loadRepositories()
  }, [])

  return (
    <RepositoriesPage
      apiState={apiState}
      repositories={repositories}
      onNavigate={(url) => router.push(url)}
    />
  )
}
