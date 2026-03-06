//SPDX-License-Identifier:MIT

pragma solidity ^0.8.3;

contract Blogs{
   struct Blog{
      uint8 id;
      string title;
      string content;
      bool isRead;
      uint8 likes;
      uint8 dislike;
      bool isPublished;
      address Author;
      uint256 createdAt;
      
   }
   mapping(uint8 => mapping(address => bool)) public liked;
   mapping(uint8 => mapping(address => bool)) public disliked;
   Blog[] public blogs;
   uint8 blog_id;
   address owner;
   
   constructor(){
      owner=msg.sender;
   }
   

   function createBlog( string memory _title, string memory _content) public {
    require(msg.sender==owner,"only owner can create blog");
    blog_id =blog_id + 1;
    Blog memory newblog=Blog({
        id:blog_id,
        title:_title,
        content:_content,
        isRead:false,
        likes:0,
        dislike:0,
        isPublished:false,
        Author:msg.sender,
        createdAt:block.timestamp
        });
     blogs.push(newblog);
   }
   
   function getAllBlogs() external view returns(Blog[] memory){
    return blogs;
   }

   function getTotalBlog() public view returns(uint256){
    return blogs.length;
   }

   function publishBlog(uint8 _id) external {
      require(blogs[_id].Author == msg.sender,"You are not the author of this blog");
      blogs[_id].isPublished = true;
   }

   function likeBlog(uint8 _id) external {
    require(!liked[_id][msg.sender], "already liked");
    require(blogs[_id].isPublished, "Cant like this blog, its not publish yet");
    if(disliked[_id][msg.sender]){
        blogs[_id].dislike=blogs[_id].dislike - 1;
        disliked[_id][msg.sender] = false;
    }
    blogs[_id].likes=blogs[_id].likes + 1;
    liked[_id][msg.sender] = true;
   }

   function dislikeBlog(uint8 _id) external {
    require(!disliked[_id][msg.sender], "already disliked");
    require(blogs[_id].isPublished, "Cant dislike this blog, its not publish yet");
    if(liked[_id][msg.sender]){
        blogs[_id].likes=blogs[_id].likes - 1;
        liked[_id][msg.sender] = false;
    }
   
    blogs[_id].dislike=blogs[_id].dislike + 1;
    disliked[_id][msg.sender] = true;
   }
   

   function readBlog(uint8 _id) external {
          blogs[_id].isRead=true;
   }

   function deleteBlog(uint8 _id) external {
      require(blogs[_id].Author==msg.sender,"You are not the author");
      for(uint8 k; k<blogs.length;k++){
         if(blogs[k].id==_id){
             blogs[k] = blogs[blogs.length - 1];
               blogs.pop();
         }
      }
   }




}