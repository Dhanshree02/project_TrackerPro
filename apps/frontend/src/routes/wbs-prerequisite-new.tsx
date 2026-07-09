import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/wbs-prerequisite-new')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/wbs-prerequisite-new"!</div>
}
