import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.pexels.com',
        pathname: '/photos/**',
      },
    ],
  },
  env: {
    OPENROUTER_API_KEY: process.env.OPENROUTER_API_KEY,
  },
  output: 'standalone',
}

export default nextConfig
