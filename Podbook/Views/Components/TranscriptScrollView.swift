import SwiftUI

struct TranscriptScrollView: View {
    @ObservedObject var viewModel: TranscriptViewModel
    @Binding var currentTime: Double
    let activeColor: Color
    let inactiveColor: Color
    let backgroundColor: Color

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.segments.enumerated()), id: \.element.id) { index, segment in
                            TranscriptLine(
                                text: segment.text,
                                isActive: segment.id == viewModel.currentSegmentID,
                                isPast: false, // Simplified for binary active/inactive
                                activeColor: activeColor,
                                inactiveColor: inactiveColor
                            )
                            .id(segment.id)
                            .onTapGesture {
                                viewModel.userDidTapSegment(segment)
                            }
                        }
                    }
                    .padding(0)
                    .frame(width: 354, alignment: .topLeading)
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            if !viewModel.isUserScrolling {
                                viewModel.userDidStartScrolling()
                            }
                        }
                )
                .onChange(of: viewModel.currentSegmentID) { _, newID in
                    if !viewModel.isUserScrolling, let id = newID {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
                .onChange(of: viewModel.isUserScrolling) { _, isScrolling in
                    if !isScrolling, let id = viewModel.currentSegmentID {
                        // Spring back to current segment
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .onChange(of: currentTime) { _, newTime in
            viewModel.updateTime(newTime)
        }
    }
}
