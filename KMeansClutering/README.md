# K Means Clustering Algorithm from Scratch Implementation for Procedural Rock Generation In Roblox Studio

## About
- Task: given a Rock model which consists of parts
- Target: Generate Rock parts with similar pattern to the original Rock model using K means clustering Algorithm

##The given original Rock Model with its center points in 3D space:

<img width="307" height="398" alt="image" src="https://github.com/user-attachments/assets/c4d21085-882c-4d6d-8f50-dd9f2b3f3e96" />
<img width="357" height="362" alt="image" src="https://github.com/user-attachments/assets/d3a0ae8b-fe00-4f88-838e-0ea4f2e3c7d1" />

## K Means Clustering Proccess

https://github.com/user-attachments/assets/548fe7de-6c26-4c22-8095-251c98d32ac6

from the experiment, the maximum k-Means silhouette score is 0.88 with k = 7

---

## Procedural rock generation, flowchart framework

```mermaid
flowchart TD
    %% KMeans Algorithm Section
    A[Start: Execute KMeans Algorithm in Game] --> B[Calculate Silhouette Score]
    B --> C[Get Maximum Score]
    C --> D[Save Centroid Folder]
    D --> E[Clear Other Centroid Folders]

    %% Procedural Rock Generation Section
    E --> F[Create New Folder]
    F --> G[Generate Rock Parts Inside Folder]
    G --> H[Replace Rock Parts at Desired Positions]
    H --> I[End]


