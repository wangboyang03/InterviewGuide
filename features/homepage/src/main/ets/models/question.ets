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