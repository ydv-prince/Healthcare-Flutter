import 'package:flutter/material.dart';

// Mock data structure for an Article
class Article {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String content;

  Article({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.content,
  });
}

// Mock list of health articles
final List<Article> mockArticles = [
  Article(
    title: "The Importance of Sleep Hygiene",
    subtitle: "Simple steps to improve your sleep quality.",
    imageUrl: "https://picsum.photos/id/111/400/250",
    content: "Good sleep hygiene is essential for optimal physical and mental health. Establishing a consistent sleep schedule, ensuring your bedroom is dark and quiet, and avoiding screens before bed are key practices...",
  ),
  Article(
    title: "Understanding Gut Health",
    subtitle: "How your microbiome affects your overall well-being.",
    imageUrl: "https://picsum.photos/id/112/400/250",
    content: "The gut microbiome, a complex community of microorganisms, plays a crucial role in digestion, immune function, and mood. Eating a fiber-rich diet and incorporating probiotics can help maintain a healthy gut balance.",
  ),
  Article(
    title: "Staying Hydrated for Energy",
    subtitle: "Tips to meet your daily water intake goals.",
    imageUrl: "https://picsum.photos/id/113/400/250",
    content: "Dehydration, even mild, can significantly impact energy levels and cognitive function. Keep a water bottle handy and use reminders to sip water throughout the day, not just when you feel thirsty.",
  ),
  Article(
    title: "Mindfulness in Daily Routine",
    subtitle: "Reducing stress with simple mindful practices.",
    imageUrl: "https://picsum.photos/id/114/400/250",
    content: "Mindfulness involves focusing on the present moment without judgment. Even short periods of mindful breathing or paying full attention to a routine task can help reduce stress and improve mental clarity.",
  ),
];


class HealthArticlesList extends StatelessWidget {
  const HealthArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Articles", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mockArticles.length,
        itemBuilder: (context, index) {
          final article = mockArticles[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            child: InkWell(
              onTap: () {
                // Navigate to the article details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailsScreen(article: article),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article Image
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(article.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Article Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            article.subtitle,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Dedicated screen to read the full article
class ArticleDetailsScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                article.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              article.subtitle,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
            ),
            const Divider(height: 30),
            Text(
              article.content * 5, // Repeat content for a longer body
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}