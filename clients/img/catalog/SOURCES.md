# Catalog photography and data

The catalog contains 180 individual food products with 180 distinct image paths and 180 distinct SHA-256 hashes. Package-size variations, bundles, mixed boxes, duplicate kiwi/pepper/cabbage colors and repeated pork/beef cuts were removed. IDs remain 1–180.

109 additional images were obtained from TheMealDB's public ingredient API. The official list and image endpoint documentation is at https://www.themealdb.com/api.php. Exact source URLs and SHA-256 hashes for new images are recorded in `manifest.json`. Existing ingredient images also originated from this API. The retained template product images remain unchanged at their original paths.

The additional images were checked on visual contact sheets. Incorrect API mappings and duplicate pictures were rejected, including coriander seeds pictured as coriander leaves, wood-ear mushrooms pictured as button mushrooms, duplicate cabbage and kidney pictures, and oatmeal pictured as the existing cookies. Customer-facing names describe the actual visible food, including canned seafood, packaged sprouts, canned pineapple, ground spices and prepared meat products.

Images are for the local frontend prototype. Commercial redistribution rights have not been independently confirmed; no purchase or exclusive ownership is claimed. Verify the original template license and replacement photography before commercial publication. Prices, stock levels and ratings are illustrative frontend values; no database records or backend behavior are introduced here.
