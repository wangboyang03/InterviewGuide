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