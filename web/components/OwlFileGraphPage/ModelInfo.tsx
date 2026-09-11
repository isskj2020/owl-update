import Paper from '@mui/material/Paper'
import Typography from '@mui/material/Typography'
import Box from '@mui/material/Box'

type ModelInfoProps = {
  model: string
}

export default function ModelInfo({ model }: ModelInfoProps) {
  return (
    <Paper
      elevation={3}
      sx={{
        position: "fixed",
        right: 16,
        bottom: 16,
        zIndex: 1200,
        px: 2,
        py: 1.5,
        borderRadius: 2,
      }}
    >
      <Typography
        variant="body2"
        sx={{
          whiteSpace: "pre-line",
        }}
      >
        {model}
      </Typography>
    </Paper>
  )
}
