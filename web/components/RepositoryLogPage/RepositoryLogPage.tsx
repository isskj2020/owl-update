'use client'

import {
  Alert,
  Box,
  Link,
  LinearProgress,
  Button,
  List,
  ListItem,
  ListItemAvatar,
  Avatar,
  Typography,
  Stack,
  Divider,
} from '@mui/material'
import { useEffect, useState } from 'react'
import { apiFetchRepoLogs } from '@/lib/api'
import CommitIcon from '@mui/icons-material/Commit'
import type { ApiState, GitLog } from '@/types/types'

type RepositoryLogPageProps = {
  repository: string,
  apiState: ApiState,
  logs: GitLog[],
  onNavigate: (url: string) => void,
}

export default function RepositoryLogPage({
  repository,
  apiState,
  logs,
  onNavigate,
}: RepositoryLogPageProps) {
  return (
    <Box sx={{
      p: 3,
    }}>
      <Box sx={{
        display: 'flex',
        m: 2,
      }}>
        <Box sx={{ flexGrow: 1 }}>
          <Typography
            variant='h5'
            sx={{ mb: 2, fontWeight: 600 }}
          >
            Repository Logs
          </Typography>
        </Box>
        <Box sx={{ ml: 2 }}>
          <Button
            variant='outlined'
            color='inherit'
            onClick={() => onNavigate(`/${repository}`) }
          >
            Git Files
          </Button>
        </Box>
      </Box>
      {apiState.loading && (
        <Box sx={{
          width: '100%',
          p: 4,
        }}>
          <LinearProgress />
        </Box>
      )}

      {apiState.error && (
        <Alert severity='error'>
          {apiState.error}
        </Alert>
      )}

      <RepositoryLogView logs={logs} />
    </Box>
  )
}

function RepositoryLogView({ logs }: Props) {
  return (
    <List>
      {logs.map((log) => (
        <Stack key={log.hash}>
          <ListItem alignItems="flex-start">
            <ListItemAvatar>
              <Avatar>
                <CommitIcon />
              </Avatar>
            </ListItemAvatar>

            <Stack>
              <Typography variant="body1">
                {log.message}
              </Typography>

              <Typography
                variant="body2"
                color="secondary"
              >
                {log.hash.substring(0, 8)}
              </Typography>

              <Typography
                variant="body2"
                color="info"
              >
                {log.author} · {log.date}
              </Typography>
            </Stack>
          </ListItem>

          <Divider />
        </Stack>
      ))}
    </List>
  )
}
