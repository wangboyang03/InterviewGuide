export interface Message {
  role: 'system' | 'user' | 'assistant',
  content: string
}

export interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
  thinkingContent: string // 思考过程
  thinkingExpanded: boolean // 思考区域是否展开
}

export interface Delta {
  content?: string
  reasoning_content?: string
}

export interface Choice {
  index: number,
  delta: Delta
}

export interface Response {
  id: string,
  object: string
  created: number
  model: string
  choices: Choice[]
}