/**
 * 试题分类模型
 */

export interface QuestionType {
  id: number
  name: string
  displayNewestFlag: 0 | 1
}

export interface QuestionItem {
  id: string;
  stem: string; // 题目
  difficulty: number; // 难度
  likeCount: number; // 点赞数
  views: number; // 浏览量
  readFlag: 0 | 1; // 是否看过 0没有 1已读
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

export interface PageData<T> {
  total: number
  pageTotal: number
  rows: T[]
}

export enum SortType {
  Default = 0, // 默认
  DifficultyLow = 10, // 难度低
  DifficultyHigh = 11, // 难度高
  ViewLow = 20, // 浏览量低
  ViewHigh = 21, // 浏览量高
  Commend = 30 // 推荐
}

export interface QuestionListRequest {
  type?: number // 0或者不传，查询全部 或者类型id
  keyword?: string // 搜索关键词,(定位题目，传题号)
  questionBankType: 9 | 10 // 9面经 10小程序面试题
  sort?: SortType // 排序，默认0,可以不传，难易-10从易到难11从难道易，浏览量：20从低到高21从高到底,30推荐数据（按照权重倒序）面经默认是按照更新时间
  page?: number
  pageSize?: number
}

export interface QuestionOptionResponse {
  id: string // 题目id 标记当前题目
  type: 0 | 1 // 类型0试题 1面经
  optType: 1 | 2 // 1点赞 2收藏
}