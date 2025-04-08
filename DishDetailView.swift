import SwiftUI

struct Dish: Identifiable {
    let id = UUID()
    let title: String
    let price: String
}

struct DishDetailView: View {
    let dish: Dish
    
    var body: some View {
        VStack(spacing: 20) {
            Text(dish.title)
                .font(.largeTitle)
                .bold()
            Text("Price: \(dish.price)")
                .font(.title2)
            // Additional dish details can go here.
            Spacer()
        }
        .padding()
        .navigationTitle("Dish Detail")
    }
}

struct DishDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DishDetailView(dish: Dish(title: "Sample Dish", price: "$10"))
        }
    }
}
