# BufeTec App

BufeTec is an iOS application designed to support the Bufetec community, providing a RAG (Retrieval-Augmented Generation) chatbot powered by OpenAI and a forum for students and staff to resolve daily issues.

## Features

- RAG Chatbot using OpenAI for intelligent, context-aware responses
- Community forum for students and Bufetec staff
- User authentication (Email/Password and Google Sign-In)
- Real-time updates for forum posts and replies
- User profiles and roles (students vs. staff)

## Technical Stack

- Frontend: SwiftUI
- Backend: [Your backend technology, e.g., Firebase, custom server, etc.]
- Authentication: Firebase Authentication
- Database: [Your database, e.g., Firestore, CoreData, etc.]
- AI Integration: OpenAI API

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+
- CocoaPods (for managing dependencies)

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/BufeTec.git
   ```

2. Navigate to the project directory:
   ```
   cd BufeTec
   ```

3. Install dependencies using CocoaPods:
   ```
   pod install
   ```

4. Open the `.xcworkspace` file in Xcode:
   ```
   open BufeTec.xcworkspace
   ```

## Configuration

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file.
3. Add the `GoogleService-Info.plist` file to your Xcode project.
4. Enable Authentication methods (Email/Password and Google Sign-In) in Firebase Console.

### OpenAI API Setup

1. Sign up for an OpenAI account and obtain an API key.
2. Add the API key to your project (ensure it's not exposed in version control).

## Main Components

### Authentication (InternalLoginView)

Handles user login via email/password or Google Sign-In.

### RAG Chatbot

Implements a chatbot interface that uses OpenAI's API to provide intelligent responses based on retrieved context.

### Forum

A community space where students and staff can post questions, share information, and respond to each other's posts.

## Usage

1. Users log in using their email/password or Google account.
2. The main interface provides access to the RAG chatbot and the community forum.
3. In the chatbot, users can ask questions and receive AI-generated responses.
4. In the forum, users can create new posts, comment on existing ones, and interact with the Bufetec community.


## Acknowledgments

- OpenAI for providing the AI capabilities
- Firebase for authentication and backend services
