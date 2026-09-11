'use client'

import {
  Link,
  Alert,
  Backdrop,
  Card,
  LinearProgress,
  CardActionArea,
  CardContent,
  Typography,
  Grid,
  Stack,
  Box,
} from '@mui/material'
import AddCircleIcon from '@mui/icons-material/AddCircle'
import type { ApiState } from '@/types/types'


type RepositoriesPageProps = {
  apiState: ApiState,
  repositories: string[],
  onNavigate: (url: string) => void,
}

export default function RepositoriesPage({
  apiState,
  repositories,
  onNavigate,
}: RepositoriesPageProps) {
  return (
    <Stack spacing={2}>
      <Card sx={{ 
        mb: 4,
        width: 'fit-content',
      }}>
        <CardActionArea
          onClick={() => onNavigate('/create')}>
          <CardContent
            sx={{
              p: 3,
            }}
          >
          <Box
            sx={{
              display: 'flex',
              alignItems: 'center',
              gap: 2,
            }}
          >
            <AddCircleIcon
              sx={{
                fontSize: 48,
              }}
            />

            <Typography variant='h5'>
            Create New Repository
            </Typography>
          </Box>
          </CardContent>
        </CardActionArea>
      </Card>

      <Typography variant='h5'>
        Existing Repository
      </Typography>

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

      <Grid container spacing={2}>
        {repositories.map((repo) => (
          <Grid
            key={repo}
            size={{
              xs: 12,
              sm: 6,
              md: 4,
            }}
          >
            <Card>
              <CardActionArea
                onClick={() => onNavigate(`/${repo}`)}>
                <CardContent>
                  <Typography variant='h6'>{repo}</Typography>
                </CardContent>
              </CardActionArea>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Stack>
  )
}
