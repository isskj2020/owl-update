'use client'

const SUBCLASS = "subClassOf"
const DISJOINT = "disjointWith"
import { useTheme } from '@mui/material/styles'
import { useEffect, useRef } from 'react'
import * as d3 from 'd3'
import { 
  OWLData,
  Axioms,
  Constraint,
  Node,
  Edge
} from '@/types/types'

const circleWidth = 30
function shortenLine(source: Node, target: Node, radius: number = 30) {
  const sx = source.x ?? 0
  const tx = target.x ?? 0
  const sy = source.y ?? 0
  const ty = target.y ?? 0

  const dx = tx - sx
  const dy = ty - sy

  const length = Math.sqrt(dx * dx + dy * dy)

  return {
    x1: sx + dx / length * radius,
    y1: sy + dy / length * radius,
    x2: tx - dx / length * radius,
    y2: ty - dy / length * radius,
  }
}

type Props = {
  data: OWLData,
  focusedConstraint: Constraint | null,
  onFocusedConstraint: (c: Constraint) => void,
}

export default function Graph({
    data,
    focusedConstraint,
    onFocusedConstraint,
}: Props) {
  const containerRef = useRef<HTMLDivElement>(null)
  const svgRef = useRef<SVGSVGElement>(null)
  const viewportRef = useRef<SVGGElement>(null)
  const theme = useTheme()
  const nodeRef = useRef<
    d3.Selection<
        SVGCircleElement,
        Node,
        SVGGElement,
        unknown
    > | null
>(null)

  useEffect(() => {
    if (
      data == null ||
      !containerRef.current ||
      !svgRef.current ||
      !viewportRef.current
    ) return

    const svg = d3.select(svgRef.current)
    const viewport = d3.select(viewportRef.current)

    viewport.selectAll('*').remove()

    const nodes = data.nodes
    Object.keys(nodes).forEach((key, index) => {
      nodes[index].name = data.nodemap[nodes[index].id]
    })

    const links = data.edges

    const g = viewport

    const defs = svg.append('defs')

    defs.append('marker')
      .attr('id', 'arrow')
      .attr('viewBox', '0 -6 12 12')
      .attr('refX', 12)
      .attr('refY', 0)
      .attr('markerWidth', 8)
      .attr('markerHeight', 8)
      .attr('orient', 'auto')
      .append('path')
      .attr('d', 'M0,-6L12,0L0,6Z')
      .attr('fill', 'var(--mui-palette-graph-line)')

    defs.append('marker')
      .attr('id', 'arrow-violation')
      .attr('viewBox', '0 -6 12 12')
      .attr('refX', 12)
      .attr('refY', 0)
      .attr('markerWidth', 8)
      .attr('markerHeight', 8)
      .attr('orient', 'auto')
      .append('path')
      .attr('d', 'M0,-6L12,0L0,6Z')
      .attr('fill', 'var(--mui-palette-graph-violated)')

    const link = g
      .selectAll('line')
      .data(links)
      .join('line')
      .attr('stroke', d => {
        if (d.type === DISJOINT) {
          return 'var(--mui-palette-graph-violated)'
        } else {
          if (d.violation) {
            return 'var(--mui-palette-graph-violated)'
          } else {
            return 'var(--mui-palette-graph-line)'
          }
        }
      })
      .attr('stroke-width', d => {
        if (d.type === DISJOINT) {
          return circleWidth-10
        } else if (d.violation) {
          return 2
        } else {
          return 2
        }
      })
      .attr('marker-end', d => {
        if (d.type === DISJOINT) {
          return null
        }
        if (d.violation) {
          return 'url(#arrow-violation)'
        }
        return 'url(#arrow)'
      })


    const node = g
      .selectAll('circle')
      .data(nodes)
      .join('circle')
      .attr('id', d => d.id)
      .attr('class', 'node')
      .attr('r', circleWidth)
      .attr('fill', d => {
        if (d.name === 'owl:Thing') {
          return 'var(--mui-palette-graph-thing)'
        }
        if (d.inconsistent) {
          return 'var(--mui-palette-graph-violated)'
        }
        return 'var(--mui-palette-graph-subclass)'
      })
      .attr('stroke', 'var(--mui-palette-graph-line)')
      .attr('stroke-width', 0)
      .style('cursor', 'pointer')
      .on('mouseover', function () {
        d3.select(this).attr('stroke-width', 3)
      })
      .on('mouseout', function () {
        d3.select(this).attr('stroke-width', 0)
      })

    nodeRef.current = node


    const label = g
      .selectAll('.node-label')
      .data(nodes)
      .join('text')
      .attr('class', 'node-label')
      .attr('fill', 'var(--mui-palette-text-primary)')
      .attr('text-anchor', 'middle')
      .text(d => d.name)

    const linkLabel = g
      .selectAll('.edge-label')
      .data(links)
      .join('text')
      .attr('class', 'edge-label')
      .attr('fill', 'var(--mui-palette-text-secondary)')
      .attr('text-anchor', 'middle')
      .text(d => d.label)


    function ticked() {
      link.each(function(d) {
        if (d.type === SUBCLASS) {
          const p = shortenLine(d.source, d.target, 30)
          d3.select(this)
          .attr('x1', p.x1)
          .attr('y1', p.y1)
          .attr('x2', p.x2)
          .attr('y2', p.y2)
        } else {
          d3.select(this)
          .attr('x1', d => (d.source as Node).x ?? 0)
          .attr('y1', d => (d.source as Node).y ?? 0)
          .attr('x2', d => (d.target as Node).x ?? 0)
          .attr('y2', d => (d.target as Node).y ?? 0)
        }
      })

      node
        .attr('cx', d => d.x ?? 0)
        .attr('cy', d => d.y ?? 0)

      label
        .attr('x', d => d.x ?? 0)
        .attr('y', d => (d.y ?? 0) + 5)

      linkLabel
        .attr('x', d => (
          ((d.source as Node).x ?? 0) +
          ((d.target as Node).x ?? 0)) / 2)
        .attr('y', d => (
          ((d.source as Node).y ?? 0) +
          ((d.target as Node).y ?? 0)) / 2)
    }



    const simulation = d3.forceSimulation<Node>(nodes)
      .force('link',
        d3.forceLink<Node, Edge>(links)
          .id(d => d.id)
          .distance(100)
          .strength(1)
      )
      .force('charge',
        d3.forceManyBody<Node>()
          .strength(0)
      )
      .force('collision',
        d3.forceCollide()
          .radius(100)
      )
      .on('tick', ticked)


    function dragStart(event: d3.D3DragEvent<any, Node, any>, d: Node) {
      if (!event.active) {
        simulation.alphaTarget(0.3).restart()
      }
      d3.select(this).attr('stroke-width', 3)
    }


    function dragged(event: d3.D3DragEvent<any, Node, any>, d: Node) {
      const transform = d3.zoomTransform(svgRef.current!)
      const point = transform.invert([event.x, event.y])
      d.fx = point[0]
      d.fy = point[1]
      d3.select(this).attr('stroke-width', 3)
    }


    function dragEnd(event: d3.D3DragEvent<any, Node, any>, d: Node) {
      if (!event.active) {
        simulation.alphaTarget(0)
      }
      d.fx = null
      d.fy = null
      d3.select(this).attr('stroke-width', 0)
    }

    node.call(
      d3.drag<SVGCircleElement, Node>()
      .on('start', dragStart)
      .on('drag', dragged)
      .on('end', dragEnd)
    )

    const zoom = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.2, 5])
      .on('zoom', event => {
        viewport.attr(
          'transform',
          event.transform
        )
      })

    svg.call(zoom)

    const resize = () => {
      const { width, height } = containerRef.current!.getBoundingClientRect()

      svg
        .attr('width', width)
        .attr('height', height)

      simulation.force('center',d3.forceCenter(width / 2, height / 2))
      simulation.alpha(1).restart()
    }

    const observer = new ResizeObserver(resize)
    observer.observe(containerRef.current)

    resize()

    return () => {
      simulation.stop()
      observer.disconnect()
      svg.on('.zoom', null)
    }

  }, [data, theme])

  useEffect(() => {
    if (!focusedConstraint || !nodeRef.current) return

    nodeRef.current.attr("stroke-width", 0)
    if (focusedConstraint.type == SUBCLASS) {
      nodeRef.current.filter(d => d.name == focusedConstraint.subject).attr("stroke-width", 5)
      nodeRef.current.filter(d => d.name == focusedConstraint.parent).attr("stroke-width", 5)
    } else {
      nodeRef.current.filter(d => d.name == focusedConstraint.subject).attr("stroke-width", 5)
      nodeRef.current.filter(d => d.name == focusedConstraint.object).attr("stroke-width", 5)
    }

  }, [focusedConstraint])

  return (
    <div
      ref={containerRef}
      style={{
        width: '100%',
        height: '100%',
        overflow: 'hidden',
      }}
    >
      <svg
        ref={svgRef}
        style={{
          display: 'block',
          width: '100%',
          height: '100%',
        }}
      >
        <g ref={viewportRef} />
      </svg>
    </div>
  )
}
