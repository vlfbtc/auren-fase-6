export interface FinancialTip {
  title: string;
  description: string;
  category: string;
  priority?: 'low' | 'medium' | 'high';
  contentType?: 'tip' | 'recommendation';
  articleId?: string;
}

export interface EducationalContentItem {
  id: string;
  title: string;
  description: string;
  type: 'article' | 'video' | 'podcast';
  category: string;
  url: string;
  thumbnailUrl?: string | null;
  author?: string;
  readTimeMinutes?: number;
  tags?: string[];
}

export interface InsightsBundle {
  tips: FinancialTip[];
  content: EducationalContentItem[];
}
