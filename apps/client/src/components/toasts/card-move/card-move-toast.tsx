import { Toast } from "@doska/ui-kit"
import { ArrowRightLeft } from "lucide-react"

interface IProps {
  visible: boolean
  columnTitle: string
}

/** Shown after moving a card through the menu, where nothing else confirms it. */
export function CardMoveToast({ visible, columnTitle }: IProps) {
  return (
    <Toast visible={visible}>
      <div
        role="status"
        className="flex items-center gap-2 px-4 py-2.5 text-sm"
      >
        <ArrowRightLeft className="size-4 shrink-0 text-muted-foreground" />
        Moved to {columnTitle}
      </div>
    </Toast>
  )
}
