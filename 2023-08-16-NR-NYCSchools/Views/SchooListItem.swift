

import SwiftUI

struct SchoolListItem: View {

        let school: School

        var body: some View {
            Text(school.name)
                .lineLimit(1)
                .font(.system(.title3, design: .rounded))
                .foregroundColor(.purple)
        }
    }



struct SchoolListItem_Previews: PreviewProvider {
    static var previews: some View {
        SchoolListItem(school: School.sampleData[0])
    }
}
