# Outstanding Tasks & Future Work
## January 1, 2026

---

## ✅ **Recently Completed (Dec 29 - Jan 1)**

- [x] Implement camera scanner view with VisionKit
- [x] Integrate Apple Vision Framework for OCR
- [x] Create vocabulary extraction service with LLM
- [x] Add photo upload option (recommended method)
- [x] Implement duplicate filtering
- [x] Add multi-scan accumulation mode
- [x] Integrate Google Cloud Vision API (optional)
- [x] Add GPT-4o Vision direct processing (optional)
- [x] Improve LLM prompt for better extraction
- [x] Fix model selection button tap targets
- [x] Fix toolbar overlay on model selection
- [x] Update UI with smart defaults (GPT-4o)
- [x] Add warning messages for accuracy expectations
- [x] Create comprehensive documentation

---

## 🔴 **High Priority (This Week)**

### **Camera Scanner Refinement**
- [ ] Test with variety of textbook layouts
- [ ] Document best practices for photo quality
- [ ] Add photo quality check/warning (optional)
- [ ] Gather user feedback on accuracy
- [ ] Monitor API costs in production

### **Bug Fixes**
- [ ] Test edge cases (very long words, special characters)
- [ ] Verify duplicate filtering in all scenarios
- [ ] Test with different device sizes
- [ ] Ensure proper error handling for all API failures

### **Documentation**
- [ ] Create user-facing guide (how to scan effectively)
- [ ] Document API key setup process (OpenAI, Google)
- [ ] Add troubleshooting section
- [ ] Create video tutorial (optional)

---

## 🟡 **Medium Priority (This Month)**

### **Camera Scanner Improvements**
- [ ] Add manual editing of extracted words before saving
  - Edit German word
  - Edit Spanish translation
  - Edit example sentence
  - Remove unwanted words

- [ ] Improve instructions in UI
  - Add visual guides (icons, photos)
  - Highlight common mistakes
  - Show example of good vs bad photos

- [ ] Photo quality indicators
  - Detect blur (CoreML?)
  - Detect poor lighting
  - Suggest retake if quality is low

- [ ] Batch processing
  - Upload multiple photos at once
  - Process in queue
  - Show progress bar

### **Google Vision Evaluation**
- [ ] Compare Apple vs Google Vision across 20+ textbooks
- [ ] Measure accuracy difference
- [ ] Analyze cost/benefit
- [ ] **Decision:** Keep or remove Google Vision option

### **UX Enhancements**
- [ ] Add "Share Deck" feature (export/import)
- [ ] Implement deck templates (common textbooks)
- [ ] Add search/filter for cards
- [ ] Improve card editing UI

### **Performance**
- [ ] Optimize image compression for API calls
- [ ] Cache API responses (if appropriate)
- [ ] Lazy loading for large decks
- [ ] Background processing for scans

---

## 🟢 **Low Priority (Future)**

### **Multi-Language Support**
- [ ] French-German vocabulary extraction
- [ ] Italian-German vocabulary extraction
- [ ] English-German vocabulary extraction
- [ ] Configurable language pair selection

### **Advanced Features**
- [ ] Save scan history/sessions
- [ ] Resume incomplete scans
- [ ] Scan progress tracking
- [ ] Scan statistics (pages scanned, words extracted)

### **Social Features**
- [ ] Share decks with other users
- [ ] Collaborative deck editing
- [ ] Community deck library
- [ ] User ratings for decks

### **Gamification**
- [ ] More achievements
- [ ] Daily streaks
- [ ] Leaderboards (optional)
- [ ] Progress badges

### **Export/Import**
- [ ] Export deck as CSV
- [ ] Export deck as Anki format
- [ ] Import from other apps
- [ ] Backup/restore functionality

---

## 🔬 **Research & Exploration**

### **OCR Improvements**
- [ ] Investigate Apple's Document Scanner API
- [ ] Test Azure Computer Vision API
- [ ] Experiment with pre-processing (contrast, perspective)
- [ ] Evaluate on-device ML models for quality detection

### **LLM Optimization**
- [ ] Fine-tune GPT-4o for vocabulary extraction
- [ ] Experiment with structured outputs
- [ ] Test GPT-4o-mini with refined prompts
- [ ] Explore local LLM options (Llama, etc.)

### **Alternative Approaches**
- [ ] Handwriting recognition (for handwritten vocab lists)
- [ ] Audio input (speak words instead of typing)
- [ ] Browser extension (scan web pages)
- [ ] Integration with dictionary APIs

---

## 🐛 **Known Issues to Address**

### **Minor Bugs**
1. **Live camera scanning unreliable**
   - Status: Documented, users guided to photo upload
   - Fix: Consider improving or removing feature
   - Priority: Low (workaround exists)

2. **Some words missed in complex layouts**
   - Status: Expected (83% is industry standard)
   - Fix: Multi-scan accumulation mode
   - Priority: Low (acceptable accuracy)

3. **Example sentences sometimes generic**
   - Status: GPT-4o generates simple sentences
   - Fix: Improve prompt or use more context
   - Priority: Low (functional but could be better)

### **Edge Cases**
1. **Very long compound words** (German)
   - May get truncated or split
   - Need testing and handling

2. **Special characters** (¿, ¡, accents)
   - Generally handled well
   - Need more testing

3. **Mixed content** (text + diagrams)
   - OCR may pick up non-word text
   - LLM should filter, but verify

---

## 💡 **Ideas for Consideration**

### **Smart Features**
- [ ] Auto-detect textbook (image recognition)
- [ ] Suggest deck name based on content
- [ ] Auto-tag cards by topic
- [ ] Difficulty estimation for words

### **Learning Enhancements**
- [ ] Audio pronunciation (TTS)
- [ ] Context-based example sentences
- [ ] Word usage frequency data
- [ ] Related words suggestions

### **Integration**
- [ ] Shortcuts app integration
- [ ] Widget for daily review
- [ ] Apple Watch companion
- [ ] iPad optimized layout

---

## 🎯 **Success Criteria for Next Milestones**

### **Milestone 1: Camera Scanner Polish (Week 1)**
- ✅ 83%+ accuracy maintained
- ✅ User satisfaction > 4/5
- ✅ No critical bugs
- ✅ Documentation complete

### **Milestone 2: Production Ready (Month 1)**
- [ ] Beta testing with 10+ users
- [ ] All high-priority bugs fixed
- [ ] Cost monitoring implemented
- [ ] User guide published

### **Milestone 3: Feature Complete (Month 3)**
- [ ] All medium-priority features implemented
- [ ] Multi-language support (at least 2 more pairs)
- [ ] Export/import functionality
- [ ] App Store submission ready

---

## 📊 **Effort Estimates**

### **High Priority Tasks**
- Camera scanner refinement: **1-2 days**
- Bug fixes: **1 day**
- Documentation: **1 day**
- **Total: 3-4 days**

### **Medium Priority Tasks**
- Manual editing UI: **2-3 days**
- Batch processing: **3-4 days**
- Photo quality detection: **2-3 days**
- Google Vision evaluation: **1 day**
- **Total: 8-11 days**

### **Low Priority Tasks**
- Multi-language support: **5-7 days** (per language pair)
- Advanced features: **10-15 days**
- Social features: **15-20 days**
- **Total: 30-42 days**

---

## 🔄 **Backlog Grooming**

### **To Remove (Not Worth It)**
- [ ] ~~Live camera scanning~~ (consider removing if photo upload works well)
- [ ] ~~Google Vision~~ (if no clear benefit over Apple Vision)
- [ ] ~~GPT-4o-mini option~~ (if 17% accuracy confirmed across textbooks)

### **To Promote (Higher Priority)**
- [ ] Manual editing → High Priority (user feedback)
- [ ] Photo quality check → Medium Priority (prevents poor results)
- [ ] Batch processing → Medium Priority (UX improvement)

### **To Defer (Not Ready)**
- [ ] Social features → Wait for user base
- [ ] Gamification → Wait for core features stable
- [ ] Browser extension → Different product scope

---

## 📝 **Development Guidelines**

### **Before Starting New Feature:**
1. ✅ Write design document
2. ✅ Define success criteria
3. ✅ Estimate effort
4. ✅ Consider alternatives
5. ✅ Get feedback

### **During Development:**
1. ✅ Write tests (when applicable)
2. ✅ Document as you go
3. ✅ Test on real data
4. ✅ Consider edge cases
5. ✅ Optimize for UX first, then performance

### **After Completion:**
1. ✅ Update documentation
2. ✅ Test with real users
3. ✅ Monitor metrics
4. ✅ Gather feedback
5. ✅ Iterate based on learnings

---

## 🎯 **Current Focus**

**This Week:**
- Polish camera scanner based on real usage
- Fix any critical bugs discovered
- Complete user documentation
- Monitor costs and accuracy

**This Month:**
- Add manual editing capability
- Improve photo quality guidance
- Evaluate Google Vision (keep or remove)
- Implement batch processing

**This Quarter:**
- Multi-language support
- Export/import functionality
- Beta testing program
- App Store preparation

---

## 📈 **Metrics to Track**

### **Camera Scanner**
- [ ] Accuracy rate (words extracted / total words)
- [ ] User retry rate (% of users scanning multiple times)
- [ ] Average scans per session
- [ ] Cost per user per month
- [ ] User satisfaction rating

### **Overall App**
- [ ] Daily active users
- [ ] Cards created per user
- [ ] Review completion rate
- [ ] Retention (day 7, day 30)
- [ ] Crash rate

### **Performance**
- [ ] API response time (p50, p95, p99)
- [ ] UI responsiveness
- [ ] Battery usage
- [ ] Network usage

---

## 🏁 **Definition of Done**

A task is complete when:
- ✅ Code is written and tested
- ✅ Documentation is updated
- ✅ No critical bugs exist
- ✅ User testing is positive (if applicable)
- ✅ Performance is acceptable
- ✅ Code is reviewed (if team)
- ✅ Merged to main branch

---

**Last Updated:** January 1, 2026
**Next Review:** January 7, 2026
**Owner:** Development Team
