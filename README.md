# 📚 Book Club Organiser Native iOS Mobile Application

This project is the result of my final year BSc Computer Science project: a native iOS mobile application that enables users to create and join book clubs, and organise related events—supporting both in-person and online formats.

## ✨ Key Features

- User authentication via Firebase Authentication
- Create and manage book clubs
- Organise events (online and face-to-face)
- In-app messaging between club members
- Filtering and search functionality
- Book club current read selections

## 🛠 Technologies Used

- **Swift** — For iOS app development  
- **Firebase** — Authentication, Firestore database, and storage  
- **Figma** — For prototyping and UI/UX design
- **Google Books API** — For book searching and selections

## 📱 Screenshots
# Login and Signup
Basic user authentication via Firebase Authentication.
![login and signup@3x](https://github.com/user-attachments/assets/d98b858c-158c-4a27-af50-b178ddfc6b9f)
# Onboarding
During onboarding users select their favourite book genres and location (optional). This data will eventually be used to personalise their recommendations.
![onbboarding@3x](https://github.com/user-attachments/assets/e4cf54ca-4f34-41d6-8c74-4af0388073c2)
# Home Page
Dashboard showing the user's joined and created clubs, and upcoming events.
![home screen](https://github.com/user-attachments/assets/08f67008-b64a-4078-81f4-055bd98311a6)
# Clubs Page
Filter between joined and created clubs as well as between those which are online or in-person.
<img width="2648" alt="your joined clubs@2x" src="https://github.com/user-attachments/assets/0c147f8a-16de-43d8-82da-b69f1596a331" />
# Book Club Details
Individual book club view with club description, books read and/or currently reading, moderator and member information, and upcoming event information.
![club details](https://github.com/user-attachments/assets/63257c2b-462c-4088-9aa9-ba33fc06a781)
# Events Page with Filtering
Filter upcoming events by meeting format, book club, and day.
<img width="4857" alt="event category filters@2x" src="https://github.com/user-attachments/assets/19373461-58a5-4e6f-8e93-5be0972c5ff7" />
# Explore Page with Filtering
Browse book clubs by genre and club name.
![explore page genres](https://github.com/user-attachments/assets/869276b7-e216-4ad1-9e7c-10e9bbf50329)
# Book Search & Selection
Users can search and choose a current book for the club.
<img width="3631" alt="current read@2x" src="https://github.com/user-attachments/assets/3900ee48-9d2d-40b5-852b-0931a8960565" />
# In-App Messaging
Send and receive messages with other book club members.
<img width="2648" alt="messages@2x" src="https://github.com/user-attachments/assets/66a37fe0-13a9-44cd-8451-64bc6c4e1f24" />

## 🚧 Known Issues

- Messaging occasionally experiences concurrency issues  
- Some features are implemented but not fully polished  
- UI still requires final refinements and error handling

## 🔮 Future Plans 

- Fix known bugs
- Add book club recommendations dependant on users' preferences and location
- Improve the book club search functionality
- Handle events that are outdated
