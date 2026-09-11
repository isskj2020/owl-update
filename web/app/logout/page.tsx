'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { apiLogout } from '@/lib/api'


export default function Page() {
  const router = useRouter()

  useEffect(() => {
    apiLogout().finally(() => router.push('/auth')) 
  }, [])

  return (
    <main className='p-4'>
    </main>
  )
}
