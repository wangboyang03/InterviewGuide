export interface StudyDataResponse {
  totalTime: number;
  studyData: studyDataItem[];
}

export interface studyDataItem {
  type: string;
  list: studyDataList[];
}

export interface studyDataList {
  /**
   * 已完成的数量
   */
  done: number;
  /**
   * id
   */
  id: string;
  /**
   * 知识点分类名称/项目分类名称
   */
  name: string;
  /**
   * 总条数
   */
  total: number;
  /**
   * 未完成的数量
   */
  undone: number;
}