'use client'

import { useRouter } from 'next/navigation'
import { owlPath, redirectAuth } from '@/lib/owlpath'
import { useEffect, useState } from 'react'
import AppBar from '@mui/material/AppBar'
import UserBadge from '@/components/AppHeader/UserBadge'
import { apiAuth, errorMessage } from '@/lib/api'
import { User } from '@/types/user'
import {
  Stack,
  Button,
} from '@mui/material'


export default function Auth() {
  const router = useRouter()
  const path = owlPath()
  const [user, setUser] = useState<User|null>(null)

  useEffect(() => {
    apiAuth()
      .then((x) => setUser(x.data))
      .catch((e) => router.push('/auth'))
  }, [path.current])

  return (
    <>
      <Stack
        direction='row'
        spacing={2}
        sx={{
          p: 2,
        }}
      >
        {user == null ? (
          <Button
            variant='outlined'
            color='inherit'
            onClick={(e) => router.push('/login')}
          >Login</Button>
        ) : (
          <UserBadge user={user} />
        )}
        {user && (
          <Button
            variant='outlined'
            color='inherit'
            onClick={(e) => router.push('/logout')}
          >Logout</Button>
        )}
      </Stack>
    </>
  )
}

