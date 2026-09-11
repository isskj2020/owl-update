'use client'

import { useEffect, useState } from 'react'
import { useObjectState } from '@/lib/react'
import OwlFileGraphPage from '@/components/OwlFileGraphPage/OwlFileGraphPage'
import { 
  apiOWLLoad,
  apiOWLLoadShapley,
  apiRepoUpdate,
  apiRepoCommit,
  apiRepoReset,
  apiFetchRepoDiffs,
  apiMLModels,
  apiSuggestLLM,
  apiSuggestEmbedding,
  errorMessage,
} from '@/lib/api'
import { 
  ApiState,
  OWLData,
  Constraint,
  ConstraintResult,
} from '@/types/types'
import { useRouter } from 'next/navigation'
import { owlPath } from '@/lib/owlpath'

export default function Page() {
  const router = useRouter()
  const path = owlPath()

  const [ apiState, updateApi ] = useObjectState<ApiState>({
    loading: false,
    error: null
  })

  const [owlData, setOWLData] = useState<OWLData | null>(null)
  const [diffText, setDiffText] = useState<string>('')
  const [modelInfo, setModelInfo] = useState<>('')
  const [focusedConstraint, setFocusedConstraint] = useState<Constraint | null>(null)
  const [reload, setReload] = useState<number>(0)

  async function loadOwlData() {
    updateApi({ loading: true, error: null })
    apiOWLLoad(path.repo, path.filepath)
      .then((res) => {
        loadOwlShapley(res.data)
      })
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function loadOwlShapley(data) {
    updateApi({ loading: true, error: null })
    apiOWLLoadShapley(path.repo, path.filepath)
      .then((res) => {
        const shapleyResults = Object.values(res.data.results)
        Object.keys(data.results).forEach((k, i) => {
          const id = data.results[i].constraint['id']
          const shapley = shapleyResults.find(x => x.constraint.id == id)
          data.results[i].shapley = shapley.score
        })
        setOWLData(data)
      })
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function loadGitDiffs() {
    updateApi({ loading: true, error: null })
    apiFetchRepoDiffs(path.repo)
      .then((res) => setDiffText(res.data.text == '' ? 'Nothing to commit' : res.data.text))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function loadModelInfo() {
    updateApi({ loading: true, error: null })
    apiMLModels().then((x) => setModelInfo(x))
  }

  async function onUpdateConstraints(constraints: Constraint[]) {
    updateApi({ loading: true, error: null })
    const changes = { 
      decay_factor: owlData.decay_factor,
      namespaces: owlData.namespaces,
      constraints: constraints,
    }
    return apiRepoUpdate(path.repo, path.filepath, changes)
      .then((_) => setReload(prev => prev+1))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onResetConstraints() {
    updateApi({ loading: true, error: null })
    return apiRepoReset(path.repo, path.filepath)
      .then((_) => setReload(prev => prev+1))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onCommit(message: string) {
    updateApi({ loading: true, error: null })
    return apiRepoCommit(path.repo, path.filepath, message)
      .then((_) => router.push(`/${path.repo}`))
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  async function onSuggestML(type: string) {
    updateApi({ loading: true, error: null })
    const axioms = { 
      decay_factor: owlData.decay_factor,
      namespaces: owlData.namespaces,
      constraints: owlData.results.map(x => x.constraint),
    }
    const promise = type === 'llm' ? apiSuggestLLM(axioms) : apiSuggestEmbedding(axioms)
    return promise
      .then((res) => {
        Object.keys(owlData.results).forEach((k, i) => {
          if (owlData.results[i].violation) {
            owlData.results[i].constraint.priority = res.data.constraints[i].priority
          }
        })
        const constraints = owlData.results.map(x => x.constraint)
        onUpdateConstraints(constraints)
        setOWLData(owlData)
      })
      .catch((e) => updateApi({ error: errorMessage(e) }))
      .finally(() => updateApi({ loading: false }))
  }

  function onFocusedConstraint(c: Constraint) {
    setFocusedConstraint(c)
  }

  useEffect(() => {
    loadOwlData()
    loadGitDiffs()
  }, [reload])

  useEffect(() => {
    loadModelInfo()
  }, [])

  return (
    <OwlFileGraphPage
      diffText={diffText}
      apiState={apiState}
      repository={path.repo}
      owlData={owlData}
      modelInfo={modelInfo}
      focusedConstraint={focusedConstraint}
      onUpdateConstraints={onUpdateConstraints}
      onResetConstraints={onResetConstraints}
      onCommit={onCommit}
      onSuggestML={onSuggestML}
      onFocusedConstraint={onFocusedConstraint}
    />
  )
}
