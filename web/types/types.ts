export type FileItem = {
  isfile: boolean,
  canload: boolean,
  name: string,
  size: string,
  updated: string,
}

export type GitLog = {
  hash: string,
  author: string,
  date: string,
  message: string,
}

export type Node = {
  id: string
  name: string
  violated: boolean
  x?: number
  y?: number
  fx?: number | null
  fy?: number | null
}

export type Edge = {
  source: string | Node
  target: string | Node
  label: string
  type: string
}

export type Constraint = {
  id: string
  type: string
  subject?: string
  parent?: string
  object?: string
  priority: number
}

export type ConstraintResult = {
  constraint: Constraint,
  depth: number,
  max_depth: number,
  impact: number,
  repair_cost: number,
  violation: boolean,
  shapley: number,
}

export type OWLData = {
  violation_score: number,
  results: ConstraintResult[],
  nodes: Node[],
  edges: Edge[],
  namespaces: Record<string, string>,
}

export type User = {
  id: string,
  name: string,
  email: string,
}

export type ApiState = {
  error: string|null,
  loading: boolean,
}
