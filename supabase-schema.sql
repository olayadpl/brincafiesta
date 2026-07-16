-- Tabla de paquetes/entradas
CREATE TABLE packages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  duration TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'entrada', -- 'cumple' o 'entrada'
  active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de galería
CREATE TABLE gallery (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  url TEXT NOT NULL,
  alt TEXT DEFAULT '',
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reservaciones
CREATE TABLE reservations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  package_id UUID REFERENCES packages(id),
  package_name TEXT NOT NULL,
  date DATE NOT NULL,
  time TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT DEFAULT '',
  quantity INTEGER DEFAULT 1,
  total INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pendiente', -- 'pendiente', 'confirmada', 'cancelada'
  notes TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Policies: lectura pública para todos
CREATE POLICY "Public read packages" ON packages FOR SELECT USING (true);
CREATE POLICY "Public read gallery" ON gallery FOR SELECT USING (true);

-- Policies: escritura solo para authenticated users
CREATE POLICY "Auth insert packages" ON packages FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Auth update packages" ON packages FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Auth delete packages" ON packages FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Auth insert gallery" ON gallery FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Auth update gallery" ON gallery FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Auth delete gallery" ON gallery FOR DELETE USING (auth.role() = 'authenticated');

CREATE POLICY "Auth insert reservations" ON reservations FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Auth update reservations" ON reservations FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Auth delete reservations" ON reservations FOR DELETE USING (auth.role() = 'authenticated');

-- Policy: anyone can insert reservations (for the public form)
CREATE POLICY "Public insert reservations" ON reservations FOR INSERT WITH CHECK (true);

-- Insertar paquetes por defecto
INSERT INTO packages (name, price, duration, type, sort_order) VALUES
('Cumpleaños 2h', 2800, '2 horas', 'cumple', 1),
('Cumpleaños 3h', 3800, '3 horas', 'cumple', 2),
('Entrada 30 min', 80, '30 minutos', 'entrada', 3),
('Entrada 1 hora', 140, '1 hora', 'entrada', 4),
('Bono 6 horas', 650, '6 horas', 'entrada', 5),
('Bono 10 horas', 950, '10 horas', 'entrada', 6);

-- Crear bucket para fotos de galería
INSERT INTO storage.buckets (id, name, public) VALUES ('gallery', 'gallery', true);

-- Policy: anyone can view gallery images
CREATE POLICY "Public view gallery" ON storage.objects FOR SELECT USING (bucket_id = 'gallery');

-- Policy: authenticated users can upload
CREATE POLICY "Auth upload gallery" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'gallery' AND auth.role() = 'authenticated');

-- Policy: authenticated users can delete
CREATE POLICY "Auth delete gallery" ON storage.objects FOR DELETE USING (bucket_id = 'gallery' AND auth.role() = 'authenticated');
