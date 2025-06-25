const fs = require('fs');
const path = require('path');

const articlesDir = path.join(__dirname, '../public/data/tips/articles');
const indexPath = path.join(__dirname, '../public/data/tips/index.json');

// Read all article files
const articleFiles = fs.readdirSync(articlesDir).filter(file => file.endsWith('.json'));

const articles = [];

// Function to calculate reading time based on content
function calculateReadingTime(article) {
  // Priority 1: Use explicitly set readingTime if available
  if (article.readingTime && typeof article.readingTime === 'number') {
    return article.readingTime;
  }
  
  // Priority 2: Calculate from content
  let contentLength = 0;
  
  // Check new format (versions structure)
  if (article.versions?.ja?.content) {
    contentLength = article.versions.ja.content.length;
  } 
  // Check old format
  else if (article.content?.ja) {
    contentLength = article.content.ja.length;
  }
  // Fallback to any content field
  else if (typeof article.content === 'string') {
    contentLength = article.content.length;
  }
  
  // Calculate reading time: 500 characters per minute (Japanese text)
  // Minimum 5 minutes
  if (contentLength > 0) {
    return Math.max(5, Math.ceil(contentLength / 500));
  }
  
  // Default to 5 minutes if no content found
  return 5;
}

// Read each article and extract metadata
for (const file of articleFiles) {
  try {
    const content = fs.readFileSync(path.join(articlesDir, file), 'utf8');
    const article = JSON.parse(content);
    
    // Calculate reading time
    const calculatedReadingTime = calculateReadingTime(article);
    
    // Extract only the metadata fields needed for index
    const metadata = {
      id: article.id,
      slug: article.slug || article.id, // Use id as fallback for slug
      date: article.date,
      category: article.category,
      difficulty: article.difficulty,
      readingTime: calculatedReadingTime,
      featured: article.featured || false,
      tags: article.tags,
      // Add title and excerpt from versions
      title: article.versions ? {
        ja: article.versions.ja?.title,
        en: article.versions.en?.title || article.versions.ja?.title
      } : article.title,
      excerpt: article.versions ? {
        ja: article.versions.ja?.description,
        en: article.versions.en?.description || article.versions.ja?.description
      } : article.excerpt
    };
    
    articles.push(metadata);
  } catch (error) {
    console.error(`Error reading ${file}:`, error.message);
  }
}

// Sort articles by date (newest first)
articles.sort((a, b) => new Date(b.date) - new Date(a.date));

// Create the index structure
const index = {
  articles: articles
};

// Write the index file
fs.writeFileSync(indexPath, JSON.stringify(index, null, 2));

console.log(`Successfully rebuilt index.json with ${articles.length} articles`);
console.log('Articles included:');
articles.forEach(article => {
  console.log(`- ${article.id} (${article.date})`);
});