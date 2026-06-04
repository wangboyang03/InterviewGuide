export interface QuestionItem {
  id: string;
  stem: string; // 题目
  difficulty: number; // 难度
  likeCount: number; // 点赞数
  views: number; // 浏览量
  readFlag: 0 | 1; // 是否看过 0没有 1已读
  highLightList?: HighlightLabelStyle[]
}

export interface QuestionDetail extends QuestionItem {
  answer: string // 答案
  collectFlag: 0 | 1 // 0取消收藏 1收藏
  likeFlag: 0 | 1 // 0取消点赞 1点赞
  stage: string[] // 所属类别 用于渲染标签
}

export interface QuestionPageResponse {
  item: QuestionItem // 跳转到题目详情页用的题目数据集合
  list: QuestionItem[] // 在详情页需要拿到整个试题集合
}

export interface HighlightLabelStyle {
  text: string // 拆分后的题目
  needHighLight: boolean // 是否需要高亮
}

// export interface KeywordHighLightStyle extends QuestionItem {
//   highLightList: HighlightLabelStyle[]
// }