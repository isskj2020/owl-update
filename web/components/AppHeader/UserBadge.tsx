'use client'

import { useEffect, useState } from 'react'
import { User } from '@/types/user'
import {
  Typography,
  Avatar,
  Stack,
} from '@mui/material'


type Props = {
  user: User,
}

export default function UserBadge({ user }: Props) {
  return (
    <Stack
      direction="row"
      spacing={1}
    >
      <Avatar>
        {user.name.slice(0, 2).toUpperCase()}
      </Avatar>

      <Stack>
        <Typography variant="body2">
        {user.name}
        </Typography>

        <Typography
          variant="caption"
          color="text.secondary"
        >
        {user.email}
        </Typography>
      </Stack>
    </Stack>
  )
}
