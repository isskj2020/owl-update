'use client'

import { useRouter } from 'next/navigation'
import CreateRepositoryForm from '@/components/CreateRepoForm/CreateRepoForm'
import { apiCreateRepo } from '@/lib/api'
import { errorMessage } from '@/lib/api'
import { useObjectState } from '@/lib/react'
import type { ApiState } from '@/types/types'

export default function Page() {
  const router = useRouter()
  const [apiState, updateApi] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  async function onSubmit({ name, description, remoteOrigin }: CreateRepoState) {
    updateApi({ loading: true })
    return apiCreateRepo(name, description, remoteOrigin)
      .then((x) => router.push('/'))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  return ( 
    <CreateRepositoryForm
      apiState={apiState}
      onSubmit={onSubmit}
    />
  )
}
