import { For } from 'solid-js'
import { Table } from '~/components/ui/table'

export const LogTable = () => {
  return <Table.Root>
    <Table.Head>
      <Table.Row>
        <Table.Header>
          Level
        </Table.Header>
        <Table.Header>
          Message
        </Table.Header>
      </Table.Row>
    </Table.Head>

  </Table.Root>
}