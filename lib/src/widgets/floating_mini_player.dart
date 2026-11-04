import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/mini_player_provider.dart';
import '../screens/video_player_screen.dart';

class FloatingMiniPlayer extends StatefulWidget {
  const FloatingMiniPlayer({super.key});

  @override
  State<FloatingMiniPlayer> createState() => _FloatingMiniPlayerState();
}

class _FloatingMiniPlayerState extends State<FloatingMiniPlayer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<MiniPlayerProvider>(
      builder: (context, miniPlayer, _) {
        if (!miniPlayer.isDocked ||
            miniPlayer.player == null ||
            miniPlayer.videoController == null) {
          return const SizedBox.shrink();
        }

        final player = miniPlayer.player!;
        final videoController = miniPlayer.videoController!;

        return Positioned(
          bottom: 24,
          left: 24,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Material(
              elevation: 16,
              shadowColor: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 320,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHovered
                          ? AppColors.brandRed.withValues(alpha: 0.6)
                          : AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Video output
                      Positioned.fill(
                        child: Video(
                          controller: videoController,
                          controls: NoVideoControls,
                        ),
                      ),

                      // Hover Scrim & Controls
                      AnimatedOpacity(
                        opacity: _isHovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xCC000000),
                                Color(0x66000000),
                                Color(0xCC000000),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Top Bar: Title & Close
                              Positioned(
                                top: 8,
                                left: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        miniPlayer.title ?? '',
                                        style: GoogleFonts.vazirmatn(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'بستن پلیر',
                                      onPressed: () => miniPlayer.close(),
                                    ),
                                  ],
                                ),
                              ),

                              // Center: Play / Pause
                              Center(
                                child: StreamBuilder<bool>(
                                  stream: player.stream.playing,
                                  builder: (context, snapshot) {
                                    final isPlaying = snapshot.data ?? false;
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.brandRed.withValues(
                                          alpha: 0.9,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppColors.brandRedGlow,
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        iconSize: 28,
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            miniPlayer.togglePlayPause(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Bottom Right: Maximize / Restore
                              Positioned(
                                bottom: 12,
                                right: 10,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.open_in_full_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'بزرگنمایی پلیر',
                                  onPressed: () =>
                                      _restoreToFullscreen(context, miniPlayer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Progress bar line
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: StreamBuilder<Duration>(
                          stream: player.stream.position,
                          builder: (context, snapshot) {
                            final pos = snapshot.data ?? Duration.zero;
                            final dur = player.state.duration;
                            final progress = dur.inMilliseconds > 0
                                ? (pos.inMilliseconds / dur.inMilliseconds)
                                      .clamp(0.0, 1.0)
                                : 0.0;
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.brandRed,
                              ),
                              minHeight: 3,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _restoreToFullscreen(
    BuildContext context,
    MiniPlayerProvider miniPlayer,
  ) {
    final player = miniPlayer.player;
    final videoController = miniPlayer.videoController;
    final url = miniPlayer.videoUrl;
    final title = miniPlayer.title;
    final mediaItem = miniPlayer.mediaItem;
    final episodeTitle = miniPlayer.episodeTitle;

    if (player == null || videoController == null || url == null) return;

    miniPlayer.undock();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoUrl: url,
          title: title ?? '',
          mediaItem: mediaItem,
          episodeTitle: episodeTitle,
          existingPlayer: player,
          existingVideoController: videoController,
        ),
      ),
    );
  }
}
