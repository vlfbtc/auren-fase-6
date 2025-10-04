export interface LoginResponse {
  accessToken: string;
  refreshToken?: string;
  userId: number;
}
