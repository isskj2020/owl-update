'use client'

import { useObjectState } from '@/lib/react'
import AuthForm from '@/components/AuthForm/AuthForm'
import { apiLogin, apiSignup } from '@/lib/api'
import { useRouter } from 'next/navigation'
import type { ApiState } from '@/types/types'
import { errorMessage } from '@/lib/api'


export default function Page() {
  const router = useRouter()
  const [ apiState, updateApi ] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  async function onSubmit({ mode, name, email, password, rememberMe }: AuthState) {
    updateApi({ loading: true })
    let task
    if (mode == 'login') {
      task = apiLogin(email, password, rememberMe)
    } else if (mode == 'signup') {
      task = apiSignup(name, email, password, rememberMe)
    } else {
      throw `invalid mode ${mode}`
    }
    return task.then((_) => router.push('/'))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onNavigate(url: string) {
    return router.push(url)
  }

  return (
    <AuthForm
      apiState={apiState}
      onSubmit={onSubmit}
      onNavigate={onNavigate}
    />
  )
}
