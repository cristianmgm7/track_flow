# Cover Art Testing Checklist

## Project Cover Art Tests

- [ ] Upload new cover art for project
- [ ] Verify WebP compression (check file size in Firebase Storage)
- [ ] Cover art displays immediately after upload
- [ ] Enable airplane mode → cover art still displays
- [ ] Restart app offline → cover art still displays
- [ ] Delete local cache → re-download works when online
- [ ] Project without cover art shows generated placeholder

## Track Cover Art Tests

- [ ] Create track in project without cover art → shows generated placeholder
- [ ] Create track in project with cover art → shows project cover art
- [ ] Upload track-specific cover art → shows track cover art
- [ ] Track cover art persists offline
- [ ] Delete track cover art → falls back to project cover art
- [ ] Track without cover art in project without cover art → shows generated placeholder

## Migration Tests

- [ ] Existing projects with old cover URLs backfill successfully
- [ ] Backfill logs show completion in app logs
- [ ] Old projects display cover art offline after backfill
- [ ] New projects use new storage path structure

## Error Handling Tests

- [ ] Upload with no internet → saves locally, syncs later
- [ ] Upload with corrupt image → shows error message
- [ ] Download fails during backfill → logged but doesn't crash
- [ ] Firebase Storage quota exceeded → shows appropriate error

## Performance Tests

- [ ] Cover art uploads complete in <5 seconds on good connection
- [ ] WebP compression reduces file sizes by 30-50%
- [ ] No memory leaks or crashes during upload/download
- [ ] Offline mode works reliably for cached cover art
