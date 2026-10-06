import os
import glob
import torch
import pandas as pd

def convert_pt_to_csv(data_dir="data", output_dir="csvs"):
    os.makedirs(output_dir, exist_ok=True)
    
    pt_files = glob.glob(os.path.join(data_dir, "*.pt")) + glob.glob(os.path.join(data_dir, "**", "*.pt"), recursive=True)
    pt_files = sorted(list(set(pt_files)))

    if not pt_files:
        print(f"No .pt files found in '{data_dir}' directory.")
        return

    print(f"Found {len(pt_files)} .pt file(s) in '{data_dir}':")
    for pt_file in pt_files:
        print(f" - {pt_file}")

    for pt_path in pt_files:
        base_name = os.path.splitext(os.path.basename(pt_path))[0]
        output_csv_path = os.path.join(output_dir, f"{base_name}.csv")
        print(f"\nProcessing '{pt_path}' -> '{output_csv_path}'...")

        try:
            # Load PyTorch file
            data = torch.load(pt_path, map_location=torch.device('cpu'), weights_only=False)
            
            # Check structure
            if isinstance(data, dict) or (hasattr(data, 'items') and callable(getattr(data, 'items')) and not isinstance(data, torch.Tensor)):
                structured_data = {}
                for key, value in data.items():
                    if isinstance(value, torch.Tensor):
                        structured_data[key] = value.detach().numpy().flatten().tolist()
                    else:
                        structured_data[key] = str(value)
                df = pd.DataFrame.from_dict(structured_data, orient='index').transpose()
            elif isinstance(data, torch.Tensor):
                df = pd.DataFrame(data.detach().numpy())
            else:
                df = pd.DataFrame([str(data)], columns=["Model Data"])
            
            df.to_csv(output_csv_path, index=False)
            print(f"Successfully converted '{base_name}.pt' -> '{output_csv_path}' (Shape: {df.shape})")

        except Exception as e:
            print(f"Failed to convert '{pt_path}': {e}")

if __name__ == "__main__":
    convert_pt_to_csv()
