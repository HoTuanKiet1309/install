#!/bin/sh
mongoimport --db snack-shop --collection categories --file /json/snack-shop.categories.json --jsonArray --drop
mongoimport --db snack-shop --collection snacks --file /json/snack-shop.snacks.json --jsonArray --drop
mongoimport --db snack-shop --collection users --file /json/snack-shop.users.json --jsonArray --drop
mongoimport --db snack-shop --collection addresses --file /json/snack-shop.addresses.json --jsonArray --drop
mongoimport --db snack-shop --collection coupons --file /json/snack-shop.coupons.json --jsonArray --drop
