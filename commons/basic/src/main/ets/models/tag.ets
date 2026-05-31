export interface TagInformation {
  text: string
  color: ResourceStr
}

export const AllTagInformation: Record<number, TagInformation> = {
  1: { text: '简单', color: $r("app.color.common_green") },
  2: { text: '简单', color: $r("app.color.common_green") },
  3: { text: '一般', color: $r("app.color.common_blue") },
  4: { text: '一般', color: $r("app.color.common_blue") },
  5: { text: '困难', color: $r("app.color.common_main_color") },
}