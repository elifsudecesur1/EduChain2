import React, { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';

// Example post data
const initialPosts = [
  {
    id: 1,
    user: {
      name: 'John Doe',
      profilePic: 'https://via.placeholder.com/50',
    },
    content: 'This is a post content. Just sharing some thoughts.',
    date: '2024-08-29',
    likes: 12,
    comments: [],
  },
  {
    id: 2,
    user: {
      name: 'Jane Smith',
      profilePic: 'https://via.placeholder.com/50',
    },
    content: 'Another interesting post here. Lots of exciting updates!',
    date: '2024-08-28',
    likes: 30,
    comments: [],
  },
];

const MainPage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [posts, setPosts] = useState(initialPosts);
  const [newComment, setNewComment] = useState("");

  // Get the role from localStorage or location state
  const userRole = location.state?.role || localStorage.getItem('userRole') || 'Employee';

  useEffect(() => {
    // Save the role to localStorage to persist it across sessions
    if (location.state?.role) {
      localStorage.setItem('userRole', location.state.role);
    }
  }, [location.state?.role]);

  const handleLike = (postId) => {
    const updatedPosts = posts.map((post) =>
      post.id === postId ? { ...post, likes: post.likes + 1 } : post
    );
    setPosts(updatedPosts);
  };

  const handleComment = (postId) => {
    const updatedPosts = posts.map((post) =>
      post.id === postId ? { ...post, comments: [...post.comments, newComment] } : post
    );
    setPosts(updatedPosts);
    setNewComment("");
  };

  const handleViewTasks = () => {
    navigate('/tasks');
  };

  const handlePostJob = () => {
    navigate('/post-job');
  };

  const renderSidePanel = () => {
    switch (userRole) {
      case 'Verifier':
        return (
          <div style={styles.sidePanel}>
            <h2>Verifier Dashboard</h2>
            <p>Review and verify tasks assigned to you.</p>
            <button
              onClick={handleViewTasks}
              style={styles.panelButton}
              onMouseEnter={handleMouseEnter}
              onMouseLeave={handleMouseLeave}
            >
              View Tasks
            </button>
          </div>
        );
      case 'Employer':
        return (
          <div style={styles.sidePanel}>
            <h2>Employer Dashboard</h2>
            <p>Manage your job postings and employee activities.</p>
            <button
              onClick={handlePostJob}
              style={styles.panelButton}
              onMouseEnter={handleMouseEnter}
              onMouseLeave={handleMouseLeave}
            >
              Post a Job
            </button>
          </div>
        );
      case 'Employee':
        return (
          <div style={styles.sidePanel}>
            <h2>Employee Dashboard</h2>
            <p>View your tasks and performance metrics.</p>
            <button
              onClick={handleViewTasks}
              style={styles.panelButton}
              onMouseEnter={handleMouseEnter}
              onMouseLeave={handleMouseLeave}
            >
              View Tasks
            </button>
          </div>
        );
      default:
        return null;
    }
  };

  const handleMouseEnter = (e) => {
    e.target.style.backgroundColor = '#004182'; // Darker blue
    e.target.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.2)';
  };

  const handleMouseLeave = (e) => {
    e.target.style.backgroundColor = '#0a66c2'; // Original color
    e.target.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.1)';
  };

  return (
    <div style={styles.container}>
      <div style={styles.sideContainer}>
        {renderSidePanel()}
      </div>

      <div style={styles.postContainer}>
        {posts.map((post) => (
          <div key={post.id} style={styles.post}>
            <div style={styles.postHeader}>
              <img src={post.user.profilePic} alt="Profile" style={styles.postProfilePic} />
              <div>
                <strong>{post.user.name}</strong>
                <div style={styles.postDate}>{post.date}</div>
              </div>
            </div>
            <div style={styles.postContent}>
              {post.content}
            </div>
            <div style={styles.postActions}>
              <button onClick={() => handleLike(post.id)} style={styles.postActionButton}>
                👍 {post.likes} Likes
              </button>
              <button style={styles.postActionButton}>
                💬 {post.comments.length} Comments
              </button>
              <button style={styles.postActionButton}>
                🔄 Share
              </button>
            </div>
            <div>
              {post.comments.map((comment, index) => (
                <div key={index} style={styles.postComment}>
                  <strong>{post.user.name}:</strong> {comment}
                </div>
              ))}
              <div style={styles.commentInputContainer}>
                <input
                  type="text"
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  placeholder="Write a comment..."
                  style={styles.commentInput}
                />
                <button onClick={() => handleComment(post.id)} style={styles.commentButton}>
                  Post
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    maxWidth: '1200px',
    margin: '0 auto',
    padding: '20px',
  },
  sideContainer: {
    width: '300px',
    marginRight: '20px',
  },
  sidePanel: {
    padding: '15px',
    border: '1px solid #ccc',
    borderRadius: '10px',
    backgroundColor: '#f9f9f9',
    textAlign: 'center',
  },
  panelButton: {
    marginTop: '10px',
    padding: '10px',
    backgroundColor: '#0a66c2',
    color: '#fff',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    width: '100%',
    transition: 'background-color 0.3s ease, box-shadow 0.3s ease',
    boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
  },
  postContainer: {
    flexGrow: 1,
  },
  post: {
    border: '1px solid #ccc',
    borderRadius: '10px',
    padding: '15px',
    marginBottom: '15px',
    backgroundColor: '#ffffff',
    boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)',
  },
  postHeader: {
    display: 'flex',
    alignItems: 'center',
    marginBottom: '10px',
  },
  postProfilePic: {
    borderRadius: '50%',
    marginRight: '10px',
    width: '50px',
    height: '50px',
  },
  postDate: {
    fontSize: '12px',
    color: 'gray',
  },
  postContent: {
    marginBottom: '10px',
    lineHeight: '1.6',
  },
  postActions: {
    display: 'flex',
    justifyContent: 'space-between',
    marginBottom: '10px',
  },
  postActionButton: {
    background: 'none',
    border: 'none',
    cursor: 'pointer',
    color: '#0a66c2',
    fontWeight: 'bold',
  },
  postComment: {
    marginBottom: '5px',
  },
  commentInputContainer: {
    display: 'flex',
    marginTop: '10px',
  },
  commentInput: {
    flexGrow: 1,
    padding: '8px',
    marginRight: '10px',
    borderRadius: '5px',
    border: '1px solid #ccc',
  },
  commentButton: {
    padding: '8px',
    backgroundColor: '#0a66c2',
    color: '#fff',
    border: 'none',
    borderRadius: '5px',
    cursor: 'pointer',
    transition: 'background-color 0.3s ease',
  },
};

export default MainPage;
