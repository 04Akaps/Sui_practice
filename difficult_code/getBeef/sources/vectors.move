module getbeef::vectors
{
    use std::vector;

    /// Returns true if any vector elements appear more than once
    public fun has_duplicates<T>(vec: &vector<T>): bool {
        let vec_len = vector::length(vec);
        // 3
        let i = 0;

        while (i < vec_len) {
            let i_addr = vector::borrow(vec, i); // 0번쨰 address
            let z = i + 1; // 1번부터 시작

            while (z < vec_len) {
                let z_addr = vector::borrow(vec, z); // 1번쨰 address

                if (i_addr == z_addr) {
                    return true
                };
                z = z + 1;
            };

            i = i + 1;
        };
        return false
    }

    /// Returns true if any of the elements in one vector are present in the other vector
    public fun intersect<T>(vec1: &vector<T>, vec2: &vector<T>): bool {
        let vec_len1 = vector::length(vec1);
        let vec_len2 = vector::length(vec2);

        let i1 = 0;
        while (i1 < vec_len1) {
            let addr1 = vector::borrow(vec1, i1);
            let i2 = 0;
            while (i2 < vec_len2) {
                let addr2 = vector::borrow(vec2, i2);
                if (addr1 == addr2) {
                    return true
                };
                i2 = i2 + 1;
            };
            i1 = i1 + 1;
        };
        return false
    }
}