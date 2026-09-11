'use client'

const FLOATING_POINT = 3

function wrapf(value) {
  if (value > 922337203685477 || value === undefined || value == '') {
    return "-"
  }
  return value.toFixed(FLOATING_POINT)
}

import { useEffect, useState } from 'react'
import { useObjectState } from '@/lib/react'
import {
  Box,
  Button,
  Checkbox,
  Chip,
  Slider,
  Stack,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TableSortLabel,
  Paper,
  Typography,
} from '@mui/material'

import type { 
  ApiState,
  OWLData,
  ConstraintResult,
  Constraint,
} from '@/types/types'

import MLButtonMenu from '@/components/MLButtonMenu/MLButtonMenu'

type ConstraintTableProps = {
  apiState: ApiState,
  owlData: OWLData,
  focusedConstraint: Constraint | null,
  onUpdate: (constraints: Constraint[]) => Promise<void>,
  onReset: () => Promise<void>,
  onCommit: () => Promise<void>,
  onSuggestML: (type: string) => Promise<void>,
  onFocusedConstraint: (c: Constraint | null) => void,
}

export default function ConstraintTable({
  apiState,
  owlData,
  focusedConstraint,
  onUpdate,
  onReset,
  onCommit,
  onSuggestML,
  onFocusedConstraint,
}: ConstraintTableProps) {


  const [constraintResults, setConstraintResults] = useState<ConstraintResult[]>([])
  const [violationScore, setViolationScore] = useState<number>(0)
  const [alpha, setAlpha] = useState<number>(0)
  const [deleteIds, setDeleteIds] = useState<string[]>([])
  const [sortAsc, setSortAsc] = useState(true)
  const [loading, setLoading] = useState(false)

  const onChangePriority = (id: string, priority: number) => {
    setConstraintResults(prev => prev.map(
      res => res.constraint.id == id ? { ...res, constraint: { ...res.constraint, priority }} : res))
  }

  const onCommitPriority = async (id: string, priority: number) => {
    onChangePriority(id, priority)
    await onUpdate(constraintResults.map(x => x.constraint))
  }

  const onClickReset = async () => {
    setLoading(true)
    await onReset()
    setLoading(false)
  }

  const onClickCommit = async () => {
    setLoading(true)
    await onCommit()
    setLoading(false)
  }

  const onClickSuggestML = async (type) => {
    setLoading(true)
    await onSuggestML(type)
    setLoading(false)
  }

  const toggleDelete = (id: string) => {
    setDeleteIds(prev => prev.includes(id) ? prev.filter(x => x !== id) : [ ...prev, id ])
  }

  const onClickUpdate = async () => {
    setLoading(true)
    const remains = constraintResults.filter(x => !deleteIds.includes(x.id))
    await onUpdate(remains.map(x => x.constraint))
    setLoading(false)
  }

  useEffect(() => {
    const results = [...Object.values(owlData.results)].sort(
      (a, b) => a.repair_cost - b.repair_cost
    )
    setConstraintResults(results)
    setViolationScore(owlData.violation_score)
    setAlpha(owlData.α)

    window.owlData = owlData
  }, [owlData])

  return (
    <Stack
      spacing={1}
    >
      <Stack
        direction='row'
        spacing={2}
      >
        <Button
          variant="contained"
          size="small"
          disabled={loading}
          loading={loading}
          onClick={onClickUpdate}
        >
          Update
        </Button>
        <Button
          variant="contained"
          color="secondary"
          size="small"
          disabled={loading}
          loading={loading}
          onClick={onClickReset}
        >
          Reset
        </Button>
        <Button
          variant="contained"
          color="success"
          size="small"
          disabled={loading}
          loading={loading}
          onClick={onClickCommit}
        >
          Commit
        </Button>
        <MLButtonMenu
          onSuggestML={onClickSuggestML}
        />
        <Typography
          sx={{
            lineHeight: 2,
          }}>
        Violation Score: <strong>{wrapf(violationScore)}</strong>
        </Typography>
        <Typography
          sx={{
            lineHeight: 2,
          }}>
        α: <strong>{wrapf(alpha)}</strong>
        </Typography>
      </Stack>


      <TableContainer
        component={Paper}
        sx={{
          flex: 1,
          minHeight: 0,
          overflow: 'auto',
        }}
      >
        <Table
          size="small"
          stickyHeader
        >

          <TableHead>
            <TableRow>

              <TableCell>
                Type
              </TableCell>

              <TableCell>
                Constraint
              </TableCell>

              <TableCell width={180}>
                Priority
              </TableCell>

              <TableCell>
                Violation
              </TableCell>

              <TableCell>
                Depth
              </TableCell>

              <TableCell>
                Max Depth
              </TableCell>

              <TableCell>
                Impact
              </TableCell>

              <TableCell>
                <TableSortLabel
                  active
                  direction={
                    sortAsc
                      ? 'asc'
                      : 'desc'
                  }
                  onClick={() =>
                    setSortAsc(!sortAsc)
                  }
                >
                  Repair Cost
                </TableSortLabel>
              </TableCell>
              <TableCell>
                Shapley
              </TableCell>

              <TableCell>
                Delete
              </TableCell>

            </TableRow>
          </TableHead>


          <TableBody>
            {constraintResults.map((c) => (
              <TableRow 
                key={c.id}
                hover
                onMouseEnter={() => onFocusedConstraint(c.constraint) }
                onMouseLeave={() => onFocusedConstraint(null) }
                sx={{
                  backgroundColor: focusedConstraint?.id == c.constraint.id ? 'action.selected' : 'inherit'
                }}
              >

                <TableCell>
                  {c.constraint.type}
                </TableCell>


                <TableCell>
                  {formatConstraint(c.constraint)}
                </TableCell>


                <TableCell>
                  <Stack
                    direction="row"
                    spacing={1}
                  >

                    <Slider
                      size="small"
                      value={c.constraint.priority}
                      min={0}
                      max={1}
                      step={0.01}
                      onChange={(_, value) => onChangePriority(c.constraint.id, value as number)}
                      onChangeCommitted={ (_, value) => onCommitPriority(c.constraint.id, value as number)}
                      sx={{
                        width: 100,
                      }}
                    />

                    <Box
                      sx={{
                        minWidth: 35,
                      }}
                    >
                      {wrapf(c.constraint.priority)}
                    </Box>

                  </Stack>
                </TableCell>


                <TableCell>
                  <Chip
                    size="small"
                    label={ c.violation ? 'violated' : 'safe' }
                    color={ c.violation ? 'error' : 'success' }
                  />
                </TableCell>

                <TableCell>
                  {c.depth}
                </TableCell>

                <TableCell>
                  {c.max_depth}
                </TableCell>

                <TableCell>
                  {c.impact}
                </TableCell>

                <TableCell>
                  {wrapf(c.repair_cost) ?? '-'}
                </TableCell>

                <TableCell>
                  {wrapf(c.shapley) ?? '-'}
                </TableCell>

                <TableCell>
                  <Checkbox
                    checked={deleteIds.includes(c.id)}
                    onChange={() => toggleDelete(c.id)}
                  />
                </TableCell>
              </TableRow>
            ))}

          </TableBody>

        </Table>
      </TableContainer>

    </Stack>
  )
}


function formatConstraint(c: Constraint) {
  if (c.type === 'subClassOf') {
    return `${c.subject} ⊑ ${c.parent}`
  }
  if (c.type === 'disjointWith') {
    return `${c.subject} ⊓ ${c.object} = ∅`
  }
  return '-'
}

