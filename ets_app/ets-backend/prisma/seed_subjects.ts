import 'dotenv/config';

import { PrismaPg } from '@prisma/adapter-pg';

import { PrismaClient } from '../src/generated/prisma/client.js';

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({
  adapter,
});

type SubjectSeed = {
  careerCode: string;
  plan: string;
  semestre: number;
  subjects: string[];
};

const data: SubjectSeed[] = [
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 1,
    subjects: [
      'Cálculo',
      'Análisis Vectorial',
      'Matemáticas Discretas',
      'Comunicación Oral y Escrita',
      'Fundamentos de Programación',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 2,
    subjects: [
      'Álgebra Lineal',
      'Cálculo Aplicado',
      'Mecánica y Electromagnetismo',
      'Ingeniería, Ética y Sociedad',
      'Fundamentos Económicos',
      'Algoritmos y Estructuras de Datos',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 3,
    subjects: [
      'Ecuaciones Diferenciales',
      'Circuitos Eléctricos',
      'Fundamentos de Diseño Digital',
      'Bases de Datos',
      'Finanzas Empresariales',
      'Paradigmas de Programación',
      'Análisis y Diseño de Algoritmos',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 4,
    subjects: [
      'Probabilidad y Estadística',
      'Matemáticas Avanzadas para la Ingeniería',
      'Electrónica Analógica',
      'Diseño de Sistemas Digitales',
      'Tecnologías para el Desarrollo de Aplicaciones Web',
      'Sistemas Operativos',
      'Teoría de la Computación',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 5,
    subjects: [
      'Procesamiento Digital de Señales',
      'Instrumentación y Control',
      'Arquitectura de Computadoras',
      'Análisis y Diseño de Sistemas',
      'Formulación y Evaluación de Proyectos Informáticos',
      'Compiladores',
      'Redes de Computadoras',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 6,
    subjects: [
      'Sistemas en Chip',
      'Optativa A1',
      'Optativa B1',
      'Métodos Cuantitativos para la Toma de Decisiones',
      'Ingeniería de Software',
      'Inteligencia Artificial',
      'Aplicaciones para Comunicaciones en Red',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 7,
    subjects: [
      'Desarrollo de Aplicaciones Móviles Nativas',
      'Optativa A2',
      'Optativa B2',
      'Trabajo Terminal I',
      'Sistemas Distribuidos',
      'Administración de Servicios en Red',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2020',
    semestre: 8,
    subjects: [
      'Estancia Profesional',
      'Desarrollo de Habilidades Sociales para la Alta Dirección',
      'Trabajo Terminal II',
      'Gestión Empresarial',
      'Liderazgo Personal',
    ],
  },

  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 1,
    subjects: [
      'Cálculo',
      'Análisis Vectorial',
      'Matemáticas Discretas',
      'Algoritmia y Programación Estructurada',
      'Física',
      'Comunicación Oral y Escrita',
      'Ingeniería, Ética y Sociedad',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 2,
    subjects: [
      'Ecuaciones Diferenciales',
      'Álgebra Lineal',
      'Cálculo Aplicado',
      'Estructuras de Datos',
      'Análisis Fundamental de Circuitos',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 3,
    subjects: [
      'Matemáticas Avanzadas para la Ingeniería',
      'Fundamentos Económicos',
      'Fundamentos de Diseño Digital',
      'Probabilidad y Estadística',
      'Teoría Computacional',
      'Bases de Datos',
      'Programación Orientada a Objetos',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 4,
    subjects: [
      'Diseño de Sistemas Digitales',
      'Sistemas Operativos',
      'Análisis y Diseño Orientado a Objetos',
      'Tecnologías para la Web',
      'Electrónica Analógica',
      'Administración Financiera',
      'Redes de Computadoras',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 5,
    subjects: [
      'Teoría de Comunicaciones y Señales',
      'Aplicaciones para Comunicaciones en Red',
      'Optativa A',
      'Arquitectura de Computadoras',
      'Métodos Cuantitativos para la Toma de Decisiones',
      'Introducción a los Microcontroladores',
      'Análisis de Algoritmos',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 6,
    subjects: [
      'Compiladores',
      'Optativa B',
      'Ingeniería de Software',
      'Administración de Proyectos',
      'Optativa C',
      'Optativa D',
      'Instrumentación',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 7,
    subjects: [
      'Desarrollo de Sistemas Distribuidos',
      'Administración de Servicios en Red',
      'Gestión Empresarial',
      'Electiva',
      'Liderazgo',
      'Trabajo Terminal I',
    ],
  },
  {
    careerCode: 'ISC',
    plan: '2009',
    semestre: 8,
    subjects: [
      'Trabajo Terminal II',
    ],
  },

  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 1,
    subjects: [
      'Fundamentos de Programación',
      'Matemáticas Discretas',
      'Cálculo',
      'Comunicación Oral y Escrita',
      'Mecánica y Electromagnetismo',
      'Fundamentos Económicos',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 2,
    subjects: [
      'Algoritmos y Estructuras de Datos',
      'Fundamentos de Diseño Digital',
      'Cálculo Multivariable',
      'Ingeniería, Ética y Sociedad',
      'Álgebra Lineal',
      'Finanzas Empresariales',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 3,
    subjects: [
      'Análisis y Diseño de Algoritmos',
      'Paradigmas de Programación',
      'Ecuaciones Diferenciales',
      'Bases de Datos',
      'Diseño de Sistemas Digitales',
      'Liderazgo Personal',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 4,
    subjects: [
      'Fundamentos de Inteligencia Artificial',
      'Probabilidad y Estadística',
      'Matemáticas Avanzadas para la Ingeniería',
      'Tecnologías para el Desarrollo de Aplicaciones Web',
      'Análisis y Diseño de Sistemas',
      'Procesamiento Digital de Imágenes',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 5,
    subjects: [
      'Aprendizaje de Máquina',
      'Visión Artificial',
      'Teoría de la Computación',
      'Procesamiento de Señales',
      'Algoritmos Bioinspirados',
      'Tecnologías de Lenguaje Natural',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 6,
    subjects: [
      'Cómputo Paralelo',
      'Redes Neuronales y Aprendizaje Profundo',
      'Ingeniería de Software para Sistemas Inteligentes',
      'Optativa A',
      'Optativa B',
      'Metodología de la Investigación y Divulgación Científica',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 7,
    subjects: [
      'Reconocimiento de Voz',
      'Trabajo Terminal I',
      'Formulación y Evaluación de Proyectos Informáticos',
      'Optativa C',
      'Optativa D',
    ],
  },
  {
    careerCode: 'IIA',
    plan: '2020',
    semestre: 8,
    subjects: [
      'Gestión Empresarial',
      'Trabajo Terminal II',
      'Estancia Profesional',
      'Desarrollo de Habilidades Sociales para la Alta Dirección',
    ],
  },

  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 1,
    subjects: [
      'Fundamentos de Programación',
      'Matemáticas Discretas',
      'Cálculo',
      'Comunicación Oral y Escrita',
      'Introducción a la Ciencia de Datos',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 2,
    subjects: [
      'Algoritmos y Estructuras de Datos',
      'Álgebra Lineal',
      'Cálculo Multivariable',
      'Ética y Legalidad',
      'Fundamentos Económicos',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 3,
    subjects: [
      'Análisis y Diseño de Algoritmos',
      'Programación para Ciencia de Datos',
      'Probabilidad',
      'Bases de Datos',
      'Métodos Numéricos',
      'Finanzas Empresariales',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 4,
    subjects: [
      'Desarrollo de Aplicaciones Web',
      'Cómputo de Alto Desempeño',
      'Estadística',
      'Base de Datos Avanzadas',
      'Desarrollo de Aplicaciones para Análisis de Datos',
      'Liderazgo Personal',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 5,
    subjects: [
      'Minería de Datos',
      'Matemáticas Avanzadas para Ciencia de Datos',
      'Procesos Estocásticos',
      'Aprendizaje de Máquina e Inteligencia Artificial',
      'Analítica y Visualización de Datos',
      'Metodología de la Investigación y Divulgación Científica',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 6,
    subjects: [
      'Modelado Predictivo',
      'Procesamiento de Lenguaje Natural',
      'Análisis de Series de Tiempo',
      'Analítica Avanzada de Datos',
      'Optativa A',
      'Optativa B',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 7,
    subjects: [
      'Big Data',
      'Modelos Econométricos',
      'Trabajo Terminal I',
      'Administración de Proyectos de TI',
      'Optativa C',
      'Optativa D',
    ],
  },
  {
    careerCode: 'LCD',
    plan: '2020',
    semestre: 8,
    subjects: [
      'Desarrollo de Habilidades Sociales para la Alta Dirección',
      'Gestión Empresarial',
      'Trabajo Terminal II',
      'Estancia Profesional',
    ],
  },
];

async function main() {
  for (const group of data) {
    const career = await prisma.career.findUnique({
      where: {
        code: group.careerCode,
      },
    });

    if (!career) {
      console.warn(`Carrera no encontrada: ${group.careerCode}`);
      continue;
    }

    if (!career.plans.includes(group.plan)) {
      console.warn(
        `Plan inválido para ${group.careerCode}: ${group.plan}. Se omite.`,
      );
      continue;
    }

    for (const name of group.subjects) {
      await prisma.subject.upsert({
        where: {
          careerId_plan_semestre_name: {
            careerId: career.id,
            plan: group.plan,
            semestre: group.semestre,
            name,
          },
        },
        update: {},
        create: {
          name,
          careerId: career.id,
          plan: group.plan,
          semestre: group.semestre,
        },
      });
    }
  }

  console.log('Materias insertadas correctamente.');
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });