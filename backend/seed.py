# 📂 seed.py
from datetime import time
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from models import Restaurant, Dish

async def seed_data(session: AsyncSession):
    # Prevent duplicate seeding
    result = await session.execute(select(Restaurant).limit(1))
    if result.scalars().first() is not None:
        print("💡 Database already has data. Skipping seeding.")
        return

    print("🌱 Seeding 6 restaurants...")

    restaurant_data = [
        {
            "name": "The Golden Wok",
            "address": "123 Chinatown Ave, NYC",
            "lat": 40.7128,
            "lon": -74.0060,
            "map_link": "https://www.google.com/maps?q=40.7128,-74.0060",
            "opening_hr": time(11, 0),
            "closing_hr": time(22, 0),
            "opening_days": "Everyday"
        },
        {
            "name": "Pasta Bella",
            "address": "55 Little Italy Rd, NYC",
            "lat": 40.7306,
            "lon": -73.9352,
            "map_link": "https://www.google.com/maps?q=40.7306,-73.9352",
            "opening_hr": time(12, 0),
            "closing_hr": time(23, 0),
            "opening_days": "Tue-Sun"
        },
        {
            "name": "Taco Loco",
            "address": "88 Sunset Blvd, LA",
            "lat": 34.0522,
            "lon": -118.2437,
            "map_link": "https://www.google.com/maps?q=34.0522,-118.2437",
            "opening_hr": time(10, 0),
            "closing_hr": time(21, 0),
            "opening_days": "Everyday"
        },
        {
            "name": "Sushi Zen",
            "address": "12 Shibuya Crossing, Tokyo",
            "lat": 35.6762,
            "lon": 139.6503,
            "map_link": "https://www.google.com/maps?q=35.6762,139.6503",
            "opening_hr": time(11, 30),
            "closing_hr": time(22, 30),
            "opening_days": "Wed-Mon"
        },
        {
            "name": "Burger Joint",
            "address": "200 Downtown Loop, Chicago",
            "lat": 41.8781,
            "lon": -87.6298,
            "map_link": "https://www.google.com/maps?q=41.8781,-87.6298",
            "opening_hr": time(11, 0),
            "closing_hr": time(0, 0),
            "opening_days": "Everyday"
        },
        {
            "name": "The Green Leaf",
            "address": "77 Market St, San Francisco",
            "lat": 37.7749,
            "lon": -122.4194,
            "map_link": "https://www.google.com/maps?q=37.7749,-122.4194",
            "opening_hr": time(8, 0),
            "closing_hr": time(16, 0),
            "opening_days": "Mon-Fri"
        }
    ]

    restaurants = []
    for r_dict in restaurant_data:
        db_restaurant = Restaurant(**r_dict)
        session.add(db_restaurant)
        restaurants.append(db_restaurant)

    await session.flush()  # generate IDs

    print("🌱 Seeding 15 dishes...")

    dish_data = [
        # Golden Wok (Index 0)
        {"name": "Kung Pao Chicken", "price": 15.50, "description": "Spicy chicken with peanuts", "menu_category": "Mains", "is_spicy": True, "average_rating": 4.5, "r_idx": 0},
        {"name": "Dim Sum Platter", "price": 12.00, "description": "Steamed dumplings", "menu_category": "Appetizers", "is_spicy": False, "average_rating": 4.8, "r_idx": 0},

        # Pasta Bella (Index 1)
        {"name": "Margherita Pizza", "price": 14.99, "description": "Fresh mozzarella and basil", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.2, "r_idx": 1},
        {"name": "Truffle Carbonara", "price": 18.50, "description": "Creamy pasta with black truffle", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.9, "r_idx": 1},
        {"name": "Classic Lasagna", "price": 16.00, "description": "Layered beef lasagna", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.0, "r_idx": 1},

        # Taco Loco (Index 2)
        {"name": "Street Tacos Trio", "price": 11.00, "description": "Three steak tacos with salsa", "menu_category": "Mains", "is_spicy": True, "average_rating": 4.6, "r_idx": 2},
        {"name": "Cheesy Quesadilla", "price": 7.50, "description": "Warm melted blend of cheeses, perfect for little ones", "menu_category": "Kids", "is_spicy": False, "average_rating": 4.8, "r_idx": 2},

        # Sushi Zen (Index 3)
        {"name": "Dragon Roll", "price": 16.00, "description": "Eel and avocado roll", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.7, "r_idx": 3},
        {"name": "Spicy Tonkotsu Ramen", "price": 15.00, "description": "Rich pork broth noodle soup", "menu_category": "Mains", "is_spicy": True, "average_rating": 4.5, "r_idx": 3},
        {"name": "Salmon Sashimi", "price": 18.00, "description": "Slices of fresh raw salmon", "menu_category": "Appetizers", "is_spicy": False, "average_rating": 4.9, "r_idx": 3},
        {"name": "Iced Matcha Latte", "price": 5.50, "description": "Refreshing cold green tea with milk", "menu_category": "Beverages", "is_spicy": False, "average_rating": 4.6, "r_idx": 3},

        # Burger Joint (Index 4)
        {"name": "Double Smash Burger", "price": 13.50, "description": "Two patties with house sauce", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.3, "r_idx": 4},
        {"name": "Buffalo Chicken Wings", "price": 12.00, "description": "Crispy wings tossed in hot sauce", "menu_category": "Appetizers", "is_spicy": True, "average_rating": 4.1, "r_idx": 4},
        {"name": "Sweet Potato Fries", "price": 6.00, "description": "Crispy seasoned fries", "menu_category": "Sides", "is_spicy": False, "average_rating": 4.4, "r_idx": 4},

        # The Green Leaf (Index 5)
        {"name": "Avocado Toast", "price": 10.50, "description": "Sourdough with poached egg", "menu_category": "Mains", "is_spicy": False, "average_rating": 4.2, "r_idx": 5},
        {"name": "Acai Superfood Bowl", "price": 12.00, "description": "Sweet blended berries topped with granola", "menu_category": "Dessert", "is_spicy": False, "average_rating": 4.8, "r_idx": 5}
    ]
    for d_dict in dish_data:
        r_index = d_dict.pop("r_idx")
        d_dict["restaurant_id"] = restaurants[r_index].id
        db_dish = Dish(**d_dict)
        session.add(db_dish)

    await session.commit()
    print("✅ Database successfully seeded with updated restaurant fields!")
